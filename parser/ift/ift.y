%{
#include<stdio.h>
#include<string.h>
int yylex();
int isValidDate(int day, char* month, int year);
int yyerror(char *);
// int yydebug=1;
%}

%union {
	 int  number;
	 char string[15];
}

%token IF THEN ELSE ID NUMBER LE GE EQ NE

// %type <number> D 
// %type <string> M 
// %type <number> Y 
// %type <string> date
// %type <number> num
// %type <string> str

%%

STS: S STS | S;
S: ST {printf("Statement accepted\n");};
ST: IF '(' E2 ')' THEN ST1 ELSE ST1 ';' | IF '(' E2 ')' THEN ST1 ';' ;
ST1: ST | ESTMT;
ESTMT: ID '=' EXPR ;

EXPR: EXPR '+' TERM | EXPR '-' TERM | TERM ;
TERM:	TERM '*' FACT | TERM '/' FACT | FACT ;
FACT: '(' EXPR ')'  | ID | NUMBER ;
E2: EXPR '<' EXPR | EXPR '>' EXPR | EXPR GE EXPR | EXPR LE EXPR | EXPR EQ EXPR | EXPR NE EXPR | EXPR '||' EXPR | EXPR '&&'EXPR | ID | NUMBER;

%%

extern FILE *yyin;
int main(int argc, char *argv[]){
	yyin = fopen(argv[1],"r");  
	while(!feof(yyin))
		yyparse();
	fclose(yyin);
	return 0;
}

int yyerror(char *s){
  printf("\n\nError: %s\n", s);
  return 0;
}

//Variable declarations,
//expressions,
