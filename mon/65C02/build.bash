asw main.asm  -g MAP -L -C

p2hex main.p mon65C02.s19 -F Moto -M 1 +5 -e 0x$(../resetAddr.bash)
p2bin main.p mon65C02.bin

