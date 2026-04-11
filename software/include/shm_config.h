#pragma once

// Shared configuration for producer and consumer
#define BUFFER_SIZE 32 * 1024 / 8
#define THREAD_COUNT 8  // Default thread count, can be overridden at runtime
#define QUEUE_SIZE 128  // Size of each bounded buffer queue
