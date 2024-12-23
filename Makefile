CC=gcc
ETAPA=4
_OBJ=lex.yy.o parser.tab.o main.o ast.o table.o
ODIR=obj
OBJ = $(patsubst %,$(ODIR)/%,$(_OBJ))
PARSER=parser.tab.c parser.tab.h
DEPS=lex.yy.c $(PARSER)

etapa$(ETAPA): $(OBJ)
	$(CC) -g -o $@ $^
		
$(ODIR)/%.o: %.c $(DEPS)
	mkdir -p $(ODIR)
	$(CC) -c -o $@ $<

ast: ast.h ast.c 
	gcc -fsanitize=address -g -Werror -o ast ast.c 

table: table.h table.c
	gcc -fsanitize=address -g -Werror -o table table.c

lex.yy.c: scanner.l
		flex scanner.l
		
$(PARSER): parser.y
	bison -d -g -Dparse.trace parser.y
	
compress: clean
	tar cvzf etapa$(ETAPA).tgz --exclude-vcs --exclude=teste.txt --exclude=runtests.sh --exclude=output2dot.sh --exclude=etapa$(ETAPA).tgz . 

run: 
	./etapa4 < teste.txt | ./output2dot.sh > saida.dot 
	xdot saida.dot


clean:
	rm -f $(PARSER) lex.yy.c etapa$(ETAPA) saida.dot *.gv
	rm -r -f $(ODIR)
