asw main.asm -relaxed -g MAP -L -C

p2hex main.p monZ80.s19 -F Moto -M 1 +5 -e 0x$(../resetAddr.bash)
p2bin main.p monz80.bin
