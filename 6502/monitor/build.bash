asw monitor.asm -relaxed -i ../common -g MAP -L -C

p2hex monitor.p mon6502.s19 -F Moto -M 1 +5 -e 0x$(../../util/resetAddr.bash monitor.map)
p2bin monitor.p mon6502.bin
