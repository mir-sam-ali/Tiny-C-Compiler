test: myparser
	./myparser $(test_file)
	python3 assembler/assembler.py
myparser: y.tab.c lex.yy.c y.tab.h
	g++ -std=c++11 -w -Wno-yacc  -g y.tab.c -ll -L -ly -o myparser
lex.yy.c: parser/mylex.l
	lex parser/mylex.l
y.tab.c: parser/parser.y
	yacc -d  parser/parser.y -v -Wnone
clean:
	rm -f myparser y.tab.c lex.yy.c y.tab.h y.output y.dot ICG.code ICG.vars output.asm
