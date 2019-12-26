invoice.tab.c invoice.tab.h: invoice.y
	bison -d invoice.y

lex.yy.c: invoice.l invoice.tab.h
	flex invoice.l

invoice: lex.yy.c invoice.tab.c invoice.tab.h
	g++ invoice.tab.c lex.yy.c -o invoice
clean: 
	rm -f invoice \
	lex.yy.c invoice.tab.c invoice.tab.h