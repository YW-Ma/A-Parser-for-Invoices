invoice:
	flex invoice.l
	bison -d invoice.y
	g++ invoice.tab.c lex.yy.c -o invoice
clean: 
	rm -f invoice \
	lex.yy.c invoice.tab.c invoice.tab.h