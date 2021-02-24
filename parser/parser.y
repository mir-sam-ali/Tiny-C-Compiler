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

%token <entry> IDENTIFIER

 /* Constants */
%token <entry> DEC_CONSTANT HEX_CONSTANT CHAR_CONSTANT FLOAT_CONSTANT STRING

 /* Logical and Relational operators */
%token LOGICAL_AND LOGICAL_OR LS_EQ GR_EQ EQ NOT_EQ

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
%left LOGICAL_OR
%left LOGICAL_AND
%left EQ NOT_EQ
%left '<' '>' LS_EQ GR_EQ
%left '+' '-'
%left '*' '/' '%'
%right '!'


%nonassoc UMINUS
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


%%

 /* Program is made up of multiple builder blocks. */
starter: starter builder
			 | builder;

 /* Each builder block is either a function or a declaration */
builder: function
			 | declaration
			 ;

 /* This is how a function looks like */
function: type identifier '(' argument_list ')' compound_stmt;
 
 /* Now we will define a grammar for how types can be specified */

type : data_type pointer    
     | data_type		    
		 ;

pointer: '*' pointer
    	| '*'
       ;

data_type : sign_specifier type_specifier
    	| type_specifier
    	;

sign_specifier : SIGNED
    		| UNSIGNED
    		;

type_specifier :INT              
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

 /* grammar rules for argument list */
 /* argument list can be empty */
argument_list : arguments
    	|
    	;
 /* arguments are comma separated TYPE ID pairs */
arguments : arguments ',' arg
    	| arg
    	;

 /* Each arg is a TYPE ID pair */
arg : type identifier
    ;

 /* Generic statement. Can be compound or a single statement */
stmt:compound_stmt		
    |single_stmt		
    ;

 /* The function body is covered in braces and has multiple statements. */
compound_stmt :
				'{' statements '}' 
    ;

statements:statements M stmt |
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

for_block: FOR '(' expression_stmt M expression_stmt M expression ')'  N M stmt 	         
    		 ;

if_block:IF '(' expression ')' M stmt 	%prec LOWER_THAN_ELSE
	 		

		|IF '(' expression ')' M stmt  ELSE N M stmt
			
    ;

while_block: WHILE M '(' expression	')' M  stmt 
			
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
				{
					$$ = new content_t();
					$$->truelist = $3->truelist; 
					$$->falselist = $3->falselist;
				}
    		| sub_expr	
				{
					$$ = new content_t(); 
					$$->truelist = $1->truelist; 
					$$->falselist = $1->falselist;
				}
			;

sub_expr:

		sub_expr '>' sub_expr	
			{
				type_check($1->data_type,$3->data_type,2);
				$$ = new content_t();
				gencode_rel($$, $1, $3, string(" > "));
			}
		| sub_expr '<' sub_expr
			{
				type_check($1->data_type,$3->data_type,2);
				$$ = new content_t();
				gencode_rel($$, $1, $3, string(" < "));
			}

		| sub_expr EQ sub_expr
			{
				type_check($1->data_type,$3->data_type,2);
				$$ = new content_t();
				gencode_rel($$, $1, $3, string(" == "));
			}

		| sub_expr NOT_EQ sub_expr
			{
				type_check($1->data_type,$3->data_type,2);
				$$ = new content_t();
				gencode_rel($$, $1, $3, string(" != "));
			}

		| sub_expr GR_EQ sub_expr
			{
				type_check($1->data_type,$3->data_type,2);
				$$ = new content_t();
				gencode_rel($$, $1, $3, string(" >= "));
			}

		| sub_expr LS_EQ sub_expr
			{
				type_check($1->data_type,$3->data_type,2);
				$$ = new content_t();
				gencode_rel($$, $1, $3, string(" <= "));
			}

		|sub_expr LOGICAL_AND M sub_expr
			{
				type_check($1->data_type,$4->data_type,2);
				$$ = new content_t();
				$$->data_type = $1->data_type;
				backpatch($1->truelist,$3);
				$$->truelist = $4->truelist;
				$$->falselist = merge($1->falselist,$4->falselist);
			}

		|sub_expr LOGICAL_OR M sub_expr
			{
				type_check($1->data_type,$4->data_type,2);
				$$ = new content_t();
				$$->data_type = $1->data_type;
				backpatch($1->falselist,$3);
				$$->truelist = merge($1->truelist,$4->truelist);
				$$->falselist = $4->falselist;
			}

		|'!' sub_expr
			{
				$$ = new content_t();
				$$->data_type = $2->data_type;
				$$->truelist = $2->falselist;
				$$->falselist = $2->truelist;
			}

		|arithmetic_expr
			{
				$$ = new content_t(); 
				$$->data_type = $1->data_type; 
				$$->addr = $1->addr;
			}
    	|assignment_expr
			{
				$$ = new content_t(); 
				$$->data_type = $1->data_type;
			}
		|unary_expr	
			{
				$$ = new content_t(); 
				$$->data_type = $1->data_type;
			}
    ;

assignment_expr :
	lhs assign arithmetic_expr	
			{
				type_check($1->entry->data_type,$3->data_type,1);
		 		$$ = new content_t();
				$$->data_type = $3->data_type;
		 		$$->code = $1->entry->lexeme + *$2 + $3->addr;
				gencode($$->code);
		 		rhs = 0;
			}

    |lhs assign array_access
			{
				type_check($1->entry->data_type,$3->data_type,1);
	 			$$ = new content_t();
				$$->data_type = $3->data_type;
	 			$$->code = $1->entry->lexeme + *$2 + $3->code;
				gencode($$->code);
	 			rhs = 0;
			}

    |lhs assign function_call
			{
				type_check($1->entry->data_type,$3,1); 
				$$ = new content_t(); 
				$$->data_type = $3;
			}

	|lhs assign unary_expr  
	        {
				type_check($1->entry->data_type,$3->data_type,1);
			 	$$ = new content_t();
				$$->data_type = $3->data_type;
			 	$$->code = $1->entry->lexeme + *$2 + $3->code;
				gencode($$->code);
			 	rhs = 0;
			}

	|unary_expr assign unary_expr		
			{
				type_check($1->data_type,$3->data_type,1);
				$$ = new content_t();
				$$->data_type = $3->data_type;
			 	$$->code = $1->code + *$2 + $3->code;
				gencode($$->code);
				rhs = 0;
			}
    ;

unary_expr:	
	identifier INCREMENT	
			{
				$$ = new content_t();
				$$->data_type = $1->data_type;
				$$->code = string($1->lexeme) + string("++");
				gencode($$->code);
			}

 	| identifier DECREMENT		
	 		{
				$$ = new content_t();
				$$->data_type = $1->data_type;
				$$->code = string($1->lexeme) + string("--");
				gencode($$->code);
			}

	| DECREMENT identifier	
			{
				$$ = new content_t();
				$$->data_type = $2->data_type;
				$$->code = string("--") + string($2->lexeme);
				gencode($$->code);
			}

	| INCREMENT identifier
			{
				$$ = new content_t();
				$$->data_type = $2->data_type;
				$$->code = string("++") + string($2->lexeme);
				gencode($$->code);
			}

lhs: identifier		{$$ = new content_t(); $$->entry = $1;}
   | array_access	{$$ = new content_t(); $$->code = $1->code;}
	 ;

identifier:IDENTIFIER
                {
                    if(is_declaration && !rhs)
                    {
                      $1 = insert(SYMBOL_TABLE,yytext,INT_MAX,current_dtype);
                      if($1 == NULL) 
					  	yyerror("Redeclaration of variable");
                    }
                    else
                    {
                      $1 = search_recursive(yytext);
                      if($1 == NULL) 
					  	yyerror("Variable not declared");
                    }
                    
					$$ = $1;
                }
    		 ;

assign:'=' 			{rhs=1; $$ = new string(" = ");}
    |ADD_ASSIGN 	{rhs=1; $$ = new string(" += ");}
    |SUB_ASSIGN 	{rhs=1; $$ = new string(" -= ");}
    |MUL_ASSIGN 	{rhs=1; $$ = new string(" *= ");}
    |DIV_ASSIGN 	{rhs=1;	$$ = new string(" /= ");}
    |MOD_ASSIGN 	{rhs=1; $$ = new string(" %= ");}
    ;

arithmetic_expr: arithmetic_expr '+' arithmetic_expr
					 {
						type_check($1->data_type,$3->data_type,0);
						$$ = new content_t();
						$$->data_type = $1->data_type;
						gencode_math($$, $1, $3, string(" + "));
					 }

			| arithmetic_expr '-' arithmetic_expr
			  		 {
						type_check($1->data_type,$3->data_type,0);
						$$ = new content_t();
						$$->data_type = $1->data_type;
						gencode_math($$, $1, $3, string(" - "));
					 }

			| arithmetic_expr '*' arithmetic_expr
					 {
						type_check($1->data_type,$3->data_type,0);
						$$ = new content_t();
		 				$$->data_type = $1->data_type;
						gencode_math($$, $1, $3, string(" * "));
					 }

			| arithmetic_expr '/' arithmetic_expr
					 {
						type_check($1->data_type,$3->data_type,0);
						$$ = new content_t();
						$$->data_type = $1->data_type;
						gencode_math($$, $1, $3, string(" / "));
					 }

		    | arithmetic_expr '%' arithmetic_expr
					 {
						type_check($1->data_type,$3->data_type,0);
						$$ = new content_t();
						$$->data_type = $1->data_type;
						gencode_math($$, $1, $3, string(" % "));
				 	 }

			|'(' arithmetic_expr ')'
					 {
						$$ = new content_t();
						$$->data_type = $2->data_type;
						$$->addr = $2->addr;
						$$->code = $2->code;
					 }

    		|'-' arithmetic_expr %prec UMINUS	
					 {
						$$ = new content_t();
						$$->data_type = $2->data_type;
						$$->addr = "t" + to_string(temp_var_number);
						std::string expr = $$->addr + " = " + "minus " + $2->addr;
						$$->code = $2->code + expr;
						temp_var_number++;
				 	 }

    	    |identifier
					 {
						$$ = new content_t();
						$$->data_type = $1->data_type;
	 					$$->addr = $1->lexeme;
			   		 }

    		|constant
					 {
						$$ = new content_t();
						$$->data_type = $1->data_type;
						$$->addr = to_string($1->value);
					 }
    		 ;

constant: DEC_CONSTANT 			{$1->is_constant=1; $$ = $1;}
    	| HEX_CONSTANT			{$1->is_constant=1; $$ = $1;}
		| CHAR_CONSTANT			{$1->is_constant=1; $$ = $1;}
		| FLOAT_CONSTANT		{$1->is_constant=1; $$ = $1;}
    ;

array_access: identifier '[' array_index ']'					
				{
					if(is_declaration)
					{
						if($3->value <= 0)
							yyerror("size of array is not positive");
						else if($3->is_constant)
							$1->array_dimension = $3->value;
					}
					else if($3->is_constant)
					{
						if($3->value > $1->array_dimension)
							yyerror("Array index out of bound");
						if($3->value < 0)
							yyerror("Array index cannot be negative");
					}
					
					$$ = new content_t();
					$$->data_type = $1->data_type;
					
					if($3->is_constant)
						$$->code = string($1->lexeme) + string("[") + to_string($3->value) + string("]");
					else
						$$->code = string($1->lexeme) + string("[") + string($3->lexeme) + string("]");
					$$->entry = $1;
				}

array_index: constant		{$$ = $1;}
		   | identifier		{$$ = $1;}
					 ;

function_call: identifier '(' parameter_list ')'
				{
					$$ = $1->data_type;
					check_parameter_list($1,param_list,p_idx);
					p_idx = 0;
					gencode(string("call ") + $1->lexeme);
				}

             | identifier '(' ')'	
			 	{
					$$ = $1->data_type;
				 	check_parameter_list($1,param_list,p_idx);
				 	p_idx = 0;
	 				gencode(string("call ") + $1->lexeme);
				}
         ;

parameter_list:
              parameter_list ','  parameter
              |parameter
              ;

parameter: sub_expr	
				{
					param_list[p_idx++] = $1->data_type;
					gencode(string("param ") + $1->addr);
				}
		 | STRING	
		 		{
					param_list[p_idx++] = STRING;
					gencode(string("param ") + $1->lexeme);
				}
		 ;

M: 			{$$ = nextinstr;}
 ;

N:			{
				$$ = new content_t;
				$$->nextlist = {nextinstr};
				gencode("goto _");
			}
	;

%%

void gencode(string x)
{
	std::string instruction;

	instruction = to_string(nextinstr) + string(": ") + x;
	ICG.push_back(instruction);
	nextinstr++;
}


void gencode_rel(content_t* & lhs, content_t* arg1, content_t* arg2, const string& op)
{
	lhs->data_type = arg1->data_type;

	lhs->truelist = {nextinstr};
	lhs->falselist = {nextinstr + 1};

	std::string code;

	code = string("if ") + arg1->addr + op + arg2->addr + string(" goto _");
	gencode(code);

	code = string("goto _");
	gencode(code);
}

void gencode_math(content_t* & lhs, content_t* arg1, content_t* arg2, const string& op)
{
	lhs->addr = "t" + to_string(temp_var_number);
	std::string expr = lhs->addr + string(" = ") + arg1->addr + op + arg2->addr;
	lhs->code = arg1->code + arg2->code + expr;

	temp_var_number++;

	gencode(expr);
}

void backpatch(vector<int>& v1, int number)
{
	for(int i = 0; i<v1.size(); i++)
	{
		string instruction = ICG[v1[i]];

		if(instruction.find("_") < instruction.size())
		{
			instruction.replace(instruction.find("_"),1,to_string(number));
			ICG[v1[i]] = instruction;
		}
	}
}

vector<int> merge(vector<int>& v1, vector<int>& v2)
{
	vector<int> concat;
	concat.reserve(v1.size() + v2.size());
	concat.insert(concat.end(), v1.begin(), v1.end());
	concat.insert(concat.end(), v2.begin(), v2.end());

	return concat;
}

void type_check(int left, int right, int flag)
{
	if(left != right)
	{
		switch(flag)
		{
			case 0: yyerror("Type mismatch in arithmetic expression"); break;
			case 1: yyerror("Type mismatch in assignment expression"); break;
			case 2: yyerror("Type mismatch in logical expression"); break;
		}
	}
}

void displayICG()
{
	ofstream outfile("ICG.code");

	for(int i=0; i<ICG.size();i++)
	outfile << ICG[i] <<endl;

	outfile << nextinstr << ": exit";

	outfile.close();
}

void printlist(vector<int> v){
	for(auto it:v)
		cout<<it<<" ";
	cout<<"Next: "<<nextinstr<<endl;
}

int main(int argc, char *argv[])
{
	 int i;
	 for(i=0; i<NUM_TABLES;i++)
	 {
	  symbol_table_list[i].symbol_table = NULL;
	  symbol_table_list[i].parent = -1;
	 }

	constant_table = create_table();
  symbol_table_list[0].symbol_table = create_table();
	yyin = fopen(argv[1], "r");

	if(!yyparse())
	{
		printf("\nPARSING COMPLETE\n\n\n");
	}
	else
	{
			printf("\nPARSING FAILED!\n\n\n");
	}

	displayICG();
/*
	printf("SYMBOL TABLES\n\n");
	display_all();
	printf("CONSTANT TABLE");
	display_constant_table(constant_table);*/

}

int yyerror(const char *msg)
{
	printf("Line no: %d Error message: %s Token: %s\n", yylineno, msg, yytext);
	exit(0);
}