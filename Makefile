CC=gcc
ETAPA=etapa3
_OBJ=lex.yy.o parser.tab.o main.o asd.o
ODIR=obj
OBJ = $(patsubst %,$(ODIR)/%,$(_OBJ))
PARSER=parser.tab.c parser.tab.h
DEPS=lex.yy.c $(PARSER)

$(ETAPA): $(OBJ)
	$(CC) -o $@ $^
		
$(ODIR)/%.o: %.c $(DEPS)
	mkdir -p $(ODIR)
	$(CC) -c -o $@ $<

asd: asd.h asd.c 
	gcc -fsanitize=address -g -Werror -o asd asd.c 

lex.yy.c: scanner.l
		flex scanner.l
		
$(PARSER): parser.y
	bison -d parser.y
	
compress: clean
	tar cvzf $(ETAPA).tgz --exclude-vcs --exclude=teste.txt --exclude=runtests.sh . 

run:
	echo "digraph grafo { vazio; }" > saida.dot
	xdot saida.dot &
	./$(ETAPA)


clean:
	rm -f $(PARSER) lex.yy.c $(ETAPA) 
	rm -r -f $(ODIR)
