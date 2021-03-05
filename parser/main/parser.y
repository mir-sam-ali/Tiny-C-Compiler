%{
	#include <bits/stdc++.h>
	#include "symboltable.h"
	#include "lex.yy.c"

	using namespace std;

	void yyerror(char *msg);

	#define SYMBOL_TABLE symbol_table_list[current_scope].symbol_table

  	extern entry_t** constant_table;

	int current_dtype;

	table_t symbol_table_list[NUM_TABLES];

	int is_declaration = 0;
	int rhs = 0;

%}

%union
{
	int data_type;
	entry_t* entry;
	string* op;
}

%token IDENTIFIER

 /* Constants */
%token INTEGER_LITERAL STRING_LITERAL CHAR_LITERAL

 /* Logical and Relational operators */
%token AND OR LESSTHANEQUAL GREATERTHANEQUAL EQ NEQ AMPERSAND 

 /* Short hand assignment operators */
%token MULEQ DIVEQ MODEQ PLUSEQ MINUSEQ
%token INCREMENT DECREMENT

 /* Data types */
%token SHORT INT LONG LONG_LONG SIGNED UNSIGNED CONST CHAR BOOLEAN VOID 

 /* Keywords */
%token IF FOR WHILE CONTINUE BREAK RETURN CASE DEFAULT DO ELSE SWITCH

/* operators */

%token STAR ADDITION MINUS NEGATION EXCLAIMATION DIVISION MODULO
%token SHIFTLEFT SHIFTRIGHT LESSTHAN GREATERTHAN 
%token BITXOR BITOR QUESTION ASSIGN  SHIFTLEQ SHIFTREQ BITANDEQ BITXOREQ BITOREQ HASH

%token TRUE FALSE
%token PRINTF SCANF GETS PUTS SIZEOF LOOP SUM MAX MIN

%token COMMA FULL_STOP OPEN_SQUARE CLOSE_SQUARE COLON 

%type <entry> identifier
%type <entry> constant
%type <entry> array_index

%type <op> assign;


%left COMMA
%right ASSIGN
%left OR
%left AND
%left EQ NEQ
%left LESSTHAN GREATERTHAN LESSTHANEQUAL GREATERTHANEQUAL
%left ADDITION MINUS
%left STAR DIVISION MODULO
%right EXCLAIMATION


%nonassoc UMINUS
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


%%

/* Generic statement. Can be compound or a single statement */

statements: statements stmt | ;

stmt: single_stmt | compound_stmt;

compound_stmt: '{' 
					{
						current_scope = create_new_scope();
						
					}
					statements 
				'}'
					{
						current_scope = exit_scope();
					};

 /* Now we will define a grammar for how types can be specified */

data_type : sign_specifier type_specifier {is_declaration = 1;}
    	| type_specifier {is_declaration = 1;}
    	;

sign_specifier : SIGNED
    		| UNSIGNED
    		;

type_specifier: INT {current_dtype = INT;}                           
    |SHORT   {current_dtype = SHORT;}                     
    |LONG     {current_dtype = LONG;}                                      
    |LONG_LONG     {current_dtype = LONG_LONG;}                              
	|CHAR {current_dtype = CHAR;}
    |BOOLEAN {current_dtype = BOOLEAN;}
    ;

/* The function body is covered in braces and has multiple statements. */


 /* Grammar for what constitutes every individual statement */
single_stmt: if_block	

		    |for_block	
		
	    	|while_block 
	    	|declaration 		
	    	
			|RETURN ';'	  
	
			|CONTINUE ';'	
	
			|BREAK ';'      
	
			|RETURN sub_expr ';' 
	
	    ;

for_block: FOR '('{
						current_scope = create_new_scope();
						
				} for_declaration expression_stmt expression ')' {
						is_declaration = 0;
						current_scope = exit_scope();
					}  stmt 	         
    		 ;

for_declaration:  declaration  | expression_stmt;

if_block:IF '(' expression ')' stmt %prec LOWER_THAN_ELSE
		|IF '(' expression ')' stmt ELSE stmt	
    ;

while_block: WHILE '(' expression ')'  stmt 
		;

declaration: data_type  declaration_list ';' {is_declaration = 0;}			
			 | declaration_list ';'
			 | unary_expr ';'


declaration_list: declaration_list COMMA sub_decl
					|sub_decl
					;

sub_decl: assignment_expr
    		|identifier
    		|array_access
			;

/* This is because we can have empty expession statements inside for loops */
expression_stmt: data_type expression ';'	
				| expression ';'
				| ';'	
    			;

expression: expression COMMA sub_expr
    		| sub_expr	
			;

sub_expr:

		sub_expr GREATERTHAN sub_expr	
		| sub_expr LESSTHAN sub_expr
		| sub_expr EQ sub_expr
		| sub_expr NEQ sub_expr
		| sub_expr GREATERTHANEQUAL sub_expr
		| sub_expr LESSTHANEQUAL sub_expr
		|sub_expr AND sub_expr
		|sub_expr OR sub_expr
		|EXCLAIMATION sub_expr
		|arithmetic_expr
    	|assignment_expr
		|unary_expr	
    ;

assignment_expr :
	lhs assign arithmetic_expr	  {rhs = 0;}
    |lhs assign array_access  {rhs = 0;}
	|lhs assign unary_expr    {rhs = 0;}
	|unary_expr assign unary_expr	  {rhs = 0;}	
    ;

unary_expr:	
	identifier INCREMENT	
 	| identifier DECREMENT		
	| DECREMENT identifier	
	| INCREMENT identifier

lhs: identifier	| array_access;

identifier: IDENTIFIER {
                    if(is_declaration && !rhs)
                    {
                      insert(SYMBOL_TABLE,yytext,INT_MAX,current_dtype);
                    //   if($1 == NULL) 
					//   	yyerror("Redeclaration of variable");
                    }
                    else
                    {
                      search_recursive(yytext);
                    //   if($1 == NULL) 
					//   	yyerror("Variable not declared");
                    }
                }
    		 ;

assign: ASSIGN 		{rhs = 1;}	
    |PLUSEQ 	{rhs = 1;}
    |MINUSEQ 	{rhs = 1;}
    |MULEQ 	{rhs = 1;}
    |DIVEQ 	{rhs = 1;}
    |MODEQ 	{rhs = 1;}
    ;

arithmetic_expr: arithmetic_expr ADDITION arithmetic_expr
    			| arithmetic_expr MINUS arithmetic_expr
    			| arithmetic_expr STAR arithmetic_expr
			    | arithmetic_expr DIVISION arithmetic_expr
                | arithmetic_expr MODULO arithmetic_expr
			    |'(' arithmetic_expr ')'
    		    |MINUS arithmetic_expr %prec UMINUS	
    	        |identifier
				|array_access
    		    |constant
				|array_access
    		 ;

constant: INTEGER_LITERAL | CHAR_LITERAL | TRUE | FALSE ; 			
    ;

array_access: identifier '[' array_index ']';

array_index: constant		
		   | identifier	| arithmetic_expr | unary_expr;

%%

int main(int argc, char *argv[]){
	int i;
	for(i=0; i<NUM_TABLES;i++)
	{
		symbol_table_list[i].symbol_table = NULL;
		symbol_table_list[i].parent = -1;
	}

	constant_table = create_table();
  	symbol_table_list[0].symbol_table = create_table();

    yyin = fopen(argv[1],"r"); 
    	while(!feof(yyin))
		yyparse();
	
	printf("SYMBOL TABLES\n\n");
	display_all();
	printf("CONSTANT TABLE");
	display_constant_table(constant_table);

	fclose(yyin);
	return 0;
}

void yyerror(const char *msg)
{
	printf("Line no: %d Error message: %s Token: %s\n", yylineno, msg, yytext);
	// exit(0);
}
