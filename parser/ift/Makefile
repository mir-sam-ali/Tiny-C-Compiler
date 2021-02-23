myparser: y.tab.c lex.yy.c y.tab.h
	gcc y.tab.c lex.yy.c  -g -ll -ly  -o myparser
lex.yy.c: ift.l
	lex ift.l
y.tab.c: ift.y
	yacc -v -d -t -g ift.y
clean:
	rm -f parser y.tab.c lex.yy.c y.tab.h y.output
