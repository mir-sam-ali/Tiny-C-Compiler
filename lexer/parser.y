%{
    #include <stdio.h>
    int yylex();
    int yyerror();
%}

%token OPEN_CURLY CLOSE_CURLY OPEN_PARANTHESIS CLOSE_PARANTHESIS SEMI_COLON
%token COMMA FULL_STOP OPEN_SQUARE CLOSE_SQUARE COLON
%token AUTO BREAK CASE CHAR CONST CONTINUE DEFAULT DO DOUBLE ELSE ENUM EXTERN
%token FLOAT FOR GOTO IF INLINE INT LONG REGISTER RESTRICT RETURN SHORT SIGNED SIZEOF STATIC STRUCT SWITCH
%token TYPEDEF UNION UNSIGNED VOID VOLATILE WHILE
%token NULL_LITERAL TRUE FALSE
%token PRINTF SCANF GETS PUTS SIZEOF LOOP SUM MAX MIN
%token STRING_LITERAL CHAR_LITERAL IDENTIFIER

%%


%%

extern FILE *yyin;
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