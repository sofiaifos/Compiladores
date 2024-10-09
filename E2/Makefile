CC=gcc

lex.yy.c: scanner.l
		flex scanner.l

bison: parser.y
		bison -d parser.y

etapa2: bison scanner.l lex.yy.c main.c
		$(CC) -c main.c parser.tab.c lex.yy.c
		$(CC) main.o parser.tab.o lex.yy.o -o etapa2

run:
		./etapa2

clean:
		rm etapa2
