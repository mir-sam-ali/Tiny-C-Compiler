myparser: y.tab.c lex.yy.c y.tab.h
	g++ -std=c++11 -g y.tab.c -ll -L -ly -o myparser
lex.yy.c: lexer/mylex.l
	lex lexer/mylex.l
y.tab.c: parser/parser.y
	yacc -d parser/parser.y -v
clean:
	rm -f myparser y.tab.c lex.yy.c y.tab.h y.output y.dot
