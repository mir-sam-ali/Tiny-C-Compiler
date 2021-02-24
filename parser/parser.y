%{
	#include <bits/stdc++.h>
	#include "symboltable.h"
	#include "lex.yy.c"

	using namespace std;

	int yyerror(char *msg);

	#define SYMBOL_TABLE symbol_table_list[current_scope].symbol_table

  	extern entry_t** constant_table;

	int current_dtype;

	table_t symbol_table_list[NUM_TABLES];

	int is_declaration = 0;
	int is_loop = 0;
	int is_func = 0;
	int func_type;

	int param_list[10];
	int p_idx = 0;
	int p=0;
  	int rhs = 0;

	void type_check(int,int,int);
	vector<int> merge(vector<int>& v1, vector<int>& v2);
	void backpatch(vector<int>&, int);
	void gencode(string);
	void gencode_math(content_t* & lhs, content_t* arg1, content_t* arg2, const string& op);
	void gencode_rel(content_t* & lhs, content_t* arg1, content_t* arg2, const string& op);
	void printlist(vector<int>);

	int nextinstr = 0;
	int temp_var_number = 0;

	vector<string> ICG;

%}

%union
{
	int data_type;
	entry_t* entry;
	content_t* content;
	string* op;
	vector<int>* nextlist;
	int instr;
}

%token IDENTIFIER

 /* Constants */
%token INTEGER_LITERAL

 /* Logical and Relational operators */
%token AND OR LESSTHANEQUAL GREATERTHANEQUAL EQ NEQ

 /* Short hand assignment operators */
%token MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN SUB_ASSIGN
%token INCREMENT DECREMENT

 /* Data types */
%token SHORT INT LONG LONG_LONG SIGNED UNSIGNED CONST VOID CHAR FLOAT CHAR_STAR

 /* Keywords */
%token IF FOR WHILE CONTINUE BREAK RETURN

%type <entry> identifier
%type <entry> constant
%type <entry> array_index

%type <op> assign;
%type <data_type> function_call

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


%type <instr> M
%type <content> N

%left ','
%right '='
%left OR
%left LOGICAL_AND
%left EQ NEQ
%left '<' '>' LESSTHANEQUAL GREATERTHANEQUAL
%left '+' '-'
%left '*' '/' '%'
%right '!'


%nonassoc UMINUS
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


%%

 
 /* Now we will define a grammar for how types can be specified */

data_type : sign_specifier type_specifier
    	| type_specifier
    	;

sign_specifier : SIGNED
    		| UNSIGNED
    		;

type_specifier :
    INT                                 
    |SHORT                       
    |LONG                                          
    |LONG_LONG                                  
	|CHAR
    |BOOLEAN
    ;


 /* Generic statement. Can be compound or a single statement */
stmt:compound_stmt		
    |single_stmt		
    ;

 /* The function body is covered in braces and has multiple statements. */
compound_stmt :
				'{' statements '}' 
    ;

statements:statements stmt |
    ;

 /* Grammar for what constitutes every individual statement */
single_stmt :if_block	

		    |for_block	
		
	    	|while_block 
	    	|declaration 		
	    	|function_call ';'	
			|RETURN ';'	  
	
			|CONTINUE ';'	
	
			|BREAK ';'      
	
			|RETURN sub_expr ';' 
							
	    ;

for_block: FOR '(' expression_stmt expression_stmt expression ')'  stmt 	         
    		 ;

if_block:IF '(' expression ')' stmt %prec LOWER_THAN_ELSE
		|IF '(' expression ')' stmt ELSE stmt	
    ;

while_block: WHILE '(' expression ')'  stmt 
		;

declaration: type  declaration_list ';'			
			 | declaration_list ';'
			 | unary_expr ';'


declaration_list: declaration_list ',' sub_decl
					|sub_decl
					;

sub_decl: assignment_expr
    		|identifier
    		|array_access
			;

/* This is because we can have empty expession statements inside for loops */
expression_stmt: expression ';'	  			
				| ';'	
    			;

expression: expression ',' sub_expr
    		| sub_expr	
			;

sub_expr:

		sub_expr '>' sub_expr	
		| sub_expr '<' sub_expr
		| sub_expr EQ sub_expr
		| sub_expr NEQ
	 sub_expr
		| sub_expr GREATERTHANEQUAL sub_expr
		| sub_expr LESSTHANEQUAL sub_expr
		|sub_expr LOGICAL_AND sub_expr
		|sub_expr OR sub_expr
		|'!' sub_expr
		|arithmetic_expr
    	|assignment_expr
		|unary_expr	
    ;

assignment_expr :
	lhs assign arithmetic_expr	
    |lhs assign array_access
    |lhs assign function_call
	|lhs assign unary_expr  
	|unary_expr assign unary_expr		
    ;

unary_expr:	
	identifier INCREMENT	
 	| identifier DECREMENT		
	| DECREMENT identifier	
	| INCREMENT identifier

lhs: identifier		
   | array_access
	 ;

identifier:IDENTIFIER;

assign:'=' 			
    |ADD_ASSIGN 	
    |SUB_ASSIGN 	
    |MUL_ASSIGN 	
    |DIV_ASSIGN 	
    |MOD_ASSIGN 	
    ;

arithmetic_expr: arithmetic_expr '+' arithmetic_expr
    			| arithmetic_expr '-' arithmetic_expr
    			| arithmetic_expr '*' arithmetic_expr
			    | arithmetic_expr '/' arithmetic_expr
                | arithmetic_expr '%' arithmetic_expr
			    |'(' arithmetic_expr ')'
    		    |'-' arithmetic_expr %prec UMINUS	
    	        |identifier
    		    |constant
    		 ;

constant: INTEGER_LITERAL 			
    ;

array_access: identifier '[' array_index ']';

array_index: constant		
		   | identifier	;

%%

void printlist(vector<int> v){
	for(auto it:v)
		cout<<it<<" ";
	cout<<"Next: "<<nextinstr<<endl;
}

int main(int argc, char *argv[])
{
	//  int i;
	//  for(i=0; i<NUM_TABLES;i++)
	//  {
	//   symbol_table_list[i].symbol_table = NULL;
	//   symbol_table_list[i].parent = -1;
	//  }

	// constant_table = create_table();
    // symbol_table_list[0].symbol_table = create_table();
	// yyin = fopen(argv[1], "r");

	if(!yyparse())
	{
		printf("\nPARSING COMPLETE\n\n\n");
	}
	else
	{
			printf("\nPARSING FAILED!\n\n\n");
	}

	//displayICG();
}

int yyerror(const char *msg)
{
	printf("Line no: %d Error message: %s Token: %s\n", yylineno, msg, yytext);
	exit(0);
}