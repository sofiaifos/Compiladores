CC=gcc
ETAPA=5
_OBJ=lex.yy.o parser.tab.o main.o ast.o table.o iloc.o
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

iloc: iloc.h iloc.c
	gcc -fsanitize=address -g -Werror -o iloc iloc.c	

lex.yy.c: scanner.l
		flex scanner.l
		
$(PARSER): parser.y
	bison -d -g -Dparse.trace parser.y
	
compress: clean
	tar cvzf etapa$(ETAPA).tgz --exclude-vcs --exclude=teste.txt --exclude=runtests.sh --exclude=output2dot.sh --exclude=etapa$(ETAPA).tgz --exclude=ilocsim.py . 

run: 
	./etapa4 < teste.txt | ./output2dot.sh > saida.dot 
	xdot saida.dot


clean:
	rm -f $(PARSER) lex.yy.c etapa$(ETAPA) *.tgz saida *.gv
	rm -r -f $(ODIR)
