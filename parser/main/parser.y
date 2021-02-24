%{
	#include <stdio.h>
	#include <string.h>
    extern FILE *yyin;
    int yylex();
    int yyerror();
%}

%union
{
	// int data_type;
	// entry_t* entry;
	// content_t* content;
	// string* op;
	// vector<int>* nextlist;
	// int instr;
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


%type <content> lhs
%type <content> sub_expr
%type <content> expression
%type <content> expression_stmt
%type <content> unary_expr
%type <content> arithmetic_expr
%type <content> assignment_expr
%type <content> array_access

%type <content> if_block
%type <content> for_block
%type <content> while_block
%type <content> compound_stmt

%type <content> statements
%type <content> single_stmt
%type <content> stmt


%left COMMA
%right ASSIGN
%left OR
%left LOGICAL_AND
%left EQ NEQ
%left LESSTHAN GREATERTHAN LESSTHANEQUAL GREATERTHANEQUAL
%left ADDITION MINUS
%left STAR DIVISION MODULO
%right EXCLAIMATION


%nonassoc UMINUS
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


%%

compound_stmt : '{' statements '}' | statements {printf("statements accepted\n");}  ;

statements: statements stmt | ;

/* Generic statement. Can be compound or a single statement */
stmt:compound_stmt		
    |single_stmt		
    ;


 /* Now we will define a grammar for how types can be specified */

data_type : sign_specifier type_specifier
    	| type_specifier
    	;

sign_specifier : SIGNED
    		| UNSIGNED
    		;

type_specifier: INT {printf("int accepted\n");}                           
    |SHORT                       
    |LONG                                          
    |LONG_LONG                                  
	|CHAR
    |BOOLEAN
    ;

/* The function body is covered in braces and has multiple statements. */


 /* Grammar for what constitutes every individual statement */
single_stmt :if_block	

		    |for_block	
		
	    	|while_block 
	    	|declaration 		
	    	
			|RETURN ';'	  
	
			|CONTINUE ';'	
	
			|BREAK ';'      
	
			|RETURN sub_expr ';' 
							
	    ;

for_block: FOR '(' for_declaration expression_stmt expression ')'  stmt 	         
    		 ;

for_declaration: data_type  declaration_list ';'| expression_stmt;

if_block:IF '(' expression ')' stmt %prec LOWER_THAN_ELSE
		|IF '(' expression ')' stmt ELSE stmt	
    ;

while_block: WHILE '(' expression ')'  stmt 
		;

declaration: data_type  declaration_list ';' {printf("declaration stmt recognized\n");}			
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
		|sub_expr LOGICAL_AND sub_expr
		|sub_expr OR sub_expr
		|EXCLAIMATION sub_expr
		|arithmetic_expr
    	|assignment_expr
		|unary_expr	
    ;

assignment_expr :
	lhs assign arithmetic_expr	
    |lhs assign array_access
	|lhs assign unary_expr  
	|unary_expr assign unary_expr		
    ;

unary_expr:	
	identifier INCREMENT	
 	| identifier DECREMENT		
	| DECREMENT identifier	
	| INCREMENT identifier

lhs: identifier	| array_access;

identifier: IDENTIFIER {printf("identifier recognized\n");};

assign: ASSIGN 			
    |PLUSEQ 	
    |MINUSEQ 	
    |MULEQ 	
    |DIVEQ 	
    |MODEQ 	
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

// int main(int argc, char *argv[])
// {
// 	//  int i;
// 	//  for(i=0; i<NUM_TABLES;i++)
// 	//  {
// 	//   symbol_table_list[i].symbol_table = NULL;
// 	//   symbol_table_list[i].parent = -1;
// 	//  }

// 	// constant_table = create_table();
//     // symbol_table_list[0].symbol_table = create_table();
// 	// yyin = fopen(argv[1], "r");

// 	if(!yyparse())
// 	{
// 		printf("\nPARSING COMPLETE\n\n\n");
// 	}
// 	else
// 	{
// 			printf("\nPARSING FAILED!\n\n\n");
// 	}

// 	//displayICG();
// }


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
