myparser: y.tab.c lex.yy.c y.tab.h
	g++ y.tab.c lex.yy.c  -g -ll -L -ly  -o myparser
lex.yy.c: mylex.l
	lex mylex.l
y.tab.c: parser.y
	yacc -v -d -t -g parser.y
clean:
	rm -f myparser y.tab.c lex.yy.c y.tab.h y.output y.dot
