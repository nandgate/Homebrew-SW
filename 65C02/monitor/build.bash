asw monitor.asm -relaxed -i ../common -g MAP -L -C

p2hex monitor.p mon65C02.s19 -F Moto -M 1 +5 -e 0x$(../../util/resetAddr.bash monitor.map)
p2bin monitor.p mon65C02.bin

