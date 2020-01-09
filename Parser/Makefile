invoice:
	bison -d invoice.y
	flex invoice.l
	g++ invoice.tab.c lex.yy.c -o invoice
clean: 
	rm -f invoice \
	lex.yy.c invoice.tab.c invoice.tab.h