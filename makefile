all:	compl link

FILE = game

compl:	${FILE}.s
	nasm -felf64 ${FILE}.s -o ${FILE}.o

link:	${FILE}.o
	gcc ${FILE}.o -no-pie -o ${FILE}
	rm ${FILE}.o
