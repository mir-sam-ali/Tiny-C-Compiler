myparser: y.tab.c lex.yy.c y.tab.h
	gcc y.tab.c lex.yy.c  -g -ll -L -ly  -o myparser
lex.yy.c: expr.l
	lex expr.l
y.tab.c: expr.y
	yacc -v -d -t -g expr.y
clean:
	rm -f myparser y.tab.c lex.yy.c y.tab.h y.output y.dot
