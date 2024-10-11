CC=gcc
ETAPA=etapa2
_OBJ=lex.yy.o parser.tab.o main.o
ODIR=obj
OBJ = $(patsubst %,$(ODIR)/%,$(_OBJ))
PARSER=parser.tab.c parser.tab.h
DEPS=lex.yy.c $(PARSER)

$(ETAPA): $(OBJ)
	$(CC) -o $@ $^
		
$(ODIR)/%.o: %.c $(DEPS)
	mkdir -p $(ODIR)
	$(CC) -c -o $@ $<

lex.yy.c: scanner.l
		flex scanner.l
		
$(PARSER): parser.y
	bison -d parser.y
	
compress:
	rm -f teste.txt
	tar cvzf $(FILENAME).tgz .

run:
	./$(ETAPA)

clean:
	rm -f $(PARSER) lex.yy.c $(ETAPA)
	rm -r -f $(ODIR)
