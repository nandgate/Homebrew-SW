asw main.asm  -g MAP -L -C

p2hex main.p mon6502.s19 -F Moto -M 1 +5 -e 0x$(../resetAddr.bash)
p2bin main.p mon6502.bin

#cp mon6502.s19 ../../../c/fake6502/
