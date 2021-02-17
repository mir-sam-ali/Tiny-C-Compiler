mylex: lex.yy.c lexer.h lexer.c
	gcc lexer.c lex.yy.c -ll -o mylexer 

lex.yy.c: mylex.l
	lex mylex.l

