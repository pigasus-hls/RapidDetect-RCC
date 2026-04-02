# Modify the bus:device.function to your output of lspci | grep Xilinx (function must be 1 for QDMA)
bus="01"
device="00"
function="1"
echo 100 > "/sys/bus/pci/devices/0000:${bus}:${device}.${function}/qdma/qmax"
dma-ctl qdma${bus}${device}${function} q stop idx 0 dir h2c
dma-ctl qdma${bus}${device}${function} q stop idx 1 dir c2h
dma-ctl qdma${bus}${device}${function} q del idx 0 dir h2c
dma-ctl qdma${bus}${device}${function} q del idx 1 dir c2h
dma-ctl qdma${bus}${device}${function} q add idx 0 dir h2c
dma-ctl qdma${bus}${device}${function} q add idx 1 dir c2h
dma-ctl qdma${bus}${device}${function} q start idx 0 dir h2c
dma-ctl qdma${bus}${device}${function} q start idx 1 dir c2h
