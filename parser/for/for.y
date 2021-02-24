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

data_type: sign_specifier type_specifier
    	| type_specifier
    	;

sign_specifier: SIGNED
    		| UNSIGNED
    		;

type_specifier:INT                    
    |SHORT INT                         
    |SHORT                             
    |LONG                              
	|LONG INT                          
    |LONG_LONG                         
    |LONG_LONG INT                     
	|CHAR 							   
	|FLOAT 							   
	|VOID							   
	|CHAR_STAR 
    ;				 	   

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
