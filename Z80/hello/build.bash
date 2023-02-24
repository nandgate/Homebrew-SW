asw hello.asm -relaxed -i ../common -g MAP -L -C

p2hex hello.p hello.s19 -F Moto -M 1 +5 -e 0x$(../../util/mainAddr.bash hello.map)
# p2hex hello.p hello.s19 -F Moto -M 1 +5
p2bin hello.p hello.bin
