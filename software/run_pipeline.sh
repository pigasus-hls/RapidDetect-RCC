#!/bin/bash

# Variables
TRACE_FILE=""
NUM_THREADS=""
THROTTLE=""

# Help message
usage() {
    echo "Usage: $0 -f trace_file -n num_threads -t throttle"
    echo "  -f: Path to the trace file"
    echo "  -n: Number of threads"
    echo "  -t: Throttle parameter between 0.0 and 1.0"
    exit 1
}

# Parse options
while getopts "f:n:t:h" opt; do
    case ${opt} in
        f ) TRACE_FILE=$OPTARG ;;
        n ) NUM_THREADS=$OPTARG ;;
        t ) THROTTLE=$OPTARG ;;
        h ) usage ;;
        \? ) usage ;;
    esac
done

# Check required options
if [ -z "$TRACE_FILE" ] || [ -z "$NUM_THREADS" ] || [ -z "$THROTTLE" ]; then
    echo "Error: -f, -n, and -t are all required arguments."
    usage
fi

echo "=================================================="
echo " Starting RapidDetect Pipeline (Producer + Consumer)"
echo " Trace file:  $TRACE_FILE"
echo " Threads:     $NUM_THREADS"
echo " Throttle:    $THROTTLE"
echo "=================================================="

# Ensure binaries exist
if [ ! -f ./host_producer.x ] || [ ! -f ./hyperscan_consumer.x ]; then
    echo "Error: Binaries host_producer.x or hyperscan_consumer.x not found."
    echo "Building binaries now..."
    make host_producer.x hyperscan_consumer.x
    if [ $? -ne 0 ]; then
        echo "Error: Compilation failed."
        exit 1
    fi
fi

# Clean up old log files
rm -f producer.log consumer.log

# Function to clean up background processes on exit
cleanup() {
    echo ""
    echo "Cleaning up processes..."
    if [ ! -z "$TAIL_PRODUCER_PID" ]; then
        kill $TAIL_PRODUCER_PID 2>/dev/null
    fi
    if [ ! -z "$TAIL_CONSUMER_PID" ]; then
        kill $TAIL_CONSUMER_PID 2>/dev/null
    fi
    if [ ! -z "$PRODUCER_PID" ]; then
        kill $PRODUCER_PID 2>/dev/null
    fi
    if [ ! -z "$CONSUMER_PID" ]; then
        kill $CONSUMER_PID 2>/dev/null
    fi
    wait $PRODUCER_PID 2>/dev/null
    wait $CONSUMER_PID 2>/dev/null
    echo "Cleanup complete."
}
trap cleanup EXIT INT TERM

# Launch the producer in the background
echo "Starting producer (logging to producer.log)..."
./host_producer.x -f "$TRACE_FILE" -n "$NUM_THREADS" -t "$THROTTLE" > producer.log 2>&1 &
PRODUCER_PID=$!

# Wait a brief moment for the producer to initialize and create the shared memory
sleep 2

# Check if the producer is still running
if ! kill -0 $PRODUCER_PID 2>/dev/null; then
    echo "Error: Producer failed to start. Checking producer.log:"
    cat producer.log
    exit 1
fi

# Launch the consumer in the background
echo "Starting consumer (logging to consumer.log)..."
./hyperscan_consumer.x patterns_full.db "$NUM_THREADS" > consumer.log 2>&1 &
CONSUMER_PID=$!

# Wait a brief moment for the consumer to start
sleep 1

# Check if the consumer is still running
if ! kill -0 $CONSUMER_PID 2>/dev/null; then
    echo "Error: Consumer failed to start. Checking consumer.log:"
    cat consumer.log
    exit 1
fi

echo "Both processes running. Streaming outputs (Ctrl+C to stop)..."
echo "--------------------------------------------------"

# Tail both logs in background
stdbuf -oL tail -n 20 -f producer.log | stdbuf -oL sed 's/^/[PRODUCER] /' &
TAIL_PRODUCER_PID=$!
stdbuf -oL tail -n 20 -f consumer.log | stdbuf -oL sed 's/^/[CONSUMER] /' &
TAIL_CONSUMER_PID=$!

# Wait for the first process to terminate
wait -n -p FINISHED_PID $PRODUCER_PID $CONSUMER_PID
STATUS=$?

if [ -n "$FINISHED_PID" ] && [ "$FINISHED_PID" -eq "$PRODUCER_PID" ]; then
    if [ $STATUS -ne 0 ]; then
        echo "Error: Producer exited with status $STATUS. Terminating consumer..."
        kill $CONSUMER_PID 2>/dev/null
        exit $STATUS
    else
        # Producer succeeded, wait for consumer to finish processing sentinels
        wait $CONSUMER_PID 2>/dev/null
        CONSUMER_STATUS=$?
        if [ $CONSUMER_STATUS -ne 0 ]; then
            echo "Error: Consumer exited with status $CONSUMER_STATUS."
            exit $CONSUMER_STATUS
        fi
    fi
elif [ -n "$FINISHED_PID" ] && [ "$FINISHED_PID" -eq "$CONSUMER_PID" ]; then
    if [ $STATUS -ne 0 ]; then
        echo "Error: Consumer exited with status $STATUS. Terminating producer..."
        kill $PRODUCER_PID 2>/dev/null
        exit $STATUS
    else
        # Consumer exited, wait for producer
        wait $PRODUCER_PID 2>/dev/null
        PRODUCER_STATUS=$?
        if [ $PRODUCER_STATUS -ne 0 ]; then
            echo "Error: Producer exited with status $PRODUCER_STATUS."
            exit $PRODUCER_STATUS
        fi
    fi
fi

# Clean up tails
kill $TAIL_PRODUCER_PID 2>/dev/null
kill $TAIL_CONSUMER_PID 2>/dev/null

echo "--------------------------------------------------"
echo "Execution finished."
