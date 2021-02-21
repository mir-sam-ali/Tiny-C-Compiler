myparser: y.tab.c lex.yy.c y.tab.h
	gcc y.tab.c lex.yy.c  -g -ll -ly  -o myparser in
lex.yy.c: mylex.l
	lex mylex.l
y.tab.c: parser.y
	yacc -v -d -t -g parser.y
clean:
	rm -f parser y.tab.c lex.yy.c y.tab.h y.output
