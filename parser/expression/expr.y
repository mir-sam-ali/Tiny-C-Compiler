%{
    #include <stdio.h>
    extern FILE *yyin;
    int yylex();
    int yyerror();
%}

%token ID NUM REAL


%%

STS: S ';' STS | S ';' ;
S: exp {printf("Statement accepted\n");};
exp :  ID
	| exp '+' exp
	| exp '-' exp
	| exp '*' exp
	| exp '/' exp
	| '(' exp '+' exp ')'
	| '(' exp '-' exp ')'
	| '(' exp '*' exp ')'
	| '(' exp '/' exp ')'
    | '(' exp ')' 
	| consttype
	| '-' ID
	| '-' consttype
	;

consttype : NUM
	| REAL
	;
%%

int main(int argc, char *argv[]){
    yyin = fopen(argv[1],"r"); 
    	while(!feof(yyin))
		yyparse();
	fclose(yyin);
	return 0;
}

int yyerror(){
  printf("\nSyntaxerror\n");
  return 0;
}
