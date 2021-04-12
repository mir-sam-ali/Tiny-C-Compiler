%{
	#include <bits/stdc++.h>
	#include "utils/symboltable.h"
	#include <string.h>
	#include "lex.yy.c"

	using namespace std;

	void yyerror(char *msg);

	#define SYMBOL_TABLE symbol_table_list[current_scope].symbol_table

  	extern entry_t** constant_table;

	int current_dtype;
	int size;
	table_t symbol_table_list[NUM_TABLES];

	int is_declaration = 0;
	int is_loop = 0;
	int is_func = 0;
	int func_type;

	int is_array_index=0;

	int param_list[10];
	int p_idx = 0;
	int p=0;
	int rhs = 0;
	int old_is_declaration=0;
	int arr_size = 1;
	char lexeme[20];

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
	int sz;
	char lexi[32];
	vector<int>* nextlist;
	int instr;
}

%token<entry> IDENTIFIER
%token <entry> INTEGER_LITERAL CHAR_LITERAL TRUE FALSE STRING_LITERAL

 /* Constants */
// %token INTEGER_LITERAL STRING_LITERAL CHAR_LITERAL

 /* Logical and Relational operators */
%token AND OR LESSTHANEQUAL GREATERTHANEQUAL EQ NEQ AMPERSAND 

 /* Short hand assignment operators */
%token MULEQ DIVEQ MODEQ PLUSEQ MINUSEQ
%token INCREMENT DECREMENT

 /* Data types */
%token SHORT INT LONG LONG_LONG SIGNED UNSIGNED CONST CHAR BOOLEAN VOID STRING

 /* Keywords */
%token IF FOR WHILE CONTINUE BREAK RETURN CASE DEFAULT DO ELSE SWITCH

/* operators */

%token STAR ADDITION MINUS NEGATION EXCLAIMATION DIVISION MODULO
%token SHIFTLEFT SHIFTRIGHT LESSTHAN GREATERTHAN 
%token BITXOR BITOR QUESTION ASSIGN  SHIFTLEQ SHIFTREQ BITANDEQ BITXOREQ BITOREQ HASH

// %token TRUE FALSE
%token PRINTF SCANF GETS PUTS SIZEOF LOOP SUM MAX MIN

%token COMMA FULL_STOP OPEN_SQUARE CLOSE_SQUARE COLON 

%type <entry> identifier
%type <entry> constant
%type <op> assign;
%type <entry> array_index
%type <content> for_declaration
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
%type <content> N
%type <content> arr
%type <instr> M 

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

statements: statements M stmt {
									backpatch($1->nextlist,$2);
									$$ = new content_t();
									$$->nextlist = $3->nextlist;
									$$->breaklist = merge($1->breaklist,$3->breaklist);
									$$->continuelist = merge($1->continuelist,$3->continuelist);
								}| {	$$ = new content_t();	};

stmt:single_stmt {$$ = new content_t(); $$=$1;}| compound_stmt {$$ = new content_t(); $$=$1;};

compound_stmt: '{' 
					{
						if(!p)current_scope = create_new_scope();
						else p = 0;
						
					}
					statements 
				'}'
					{
						current_scope = exit_scope();
						$$ = new content_t();
						$$ = $3;
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


 /* Grammar for what constitutes every individual statement */
single_stmt: if_block {
							$$ = new content_t();
							$$ = $1;
							backpatch($$->nextlist, nextinstr);
						}	

		    |for_block	{
							$$ = new content_t();
							$$ = $1;
							backpatch($$->nextlist, nextinstr);
						}
		
	    	|while_block {
							$$ = new content_t();
							$$ = $1;
							backpatch($$->nextlist, nextinstr);
						 }
	    	|declaration {$$ = new content_t(); }		
	    	
			|CONTINUE ';' {
								if(!is_loop)
									yyerror("Illegal use of continue");
								$$ = new content_t();
								$$->continuelist = {nextinstr};
								gencode("goto _");
							}
	
			|BREAK ';' {
								if(!is_loop) {yyerror("Illegal use of break");}
								$$ = new content_t();
								$$->breaklist = {nextinstr};
								gencode("goto _");
						    }     
	
	
	    ;

for_block: FOR '(' 
					{
						current_scope = create_new_scope();
					} for_declaration M expression_stmt M expression ')' {
						is_loop = 1;
						is_declaration = 0;
						
					} N M stmt {is_loop = 0;}
					{
						backpatch($6->truelist,$12);
						backpatch($13->nextlist,$7);
						backpatch($13->continuelist, $7);
						backpatch($11->nextlist, $5);
						$$ = new content_t();
						$$->nextlist = merge($6->falselist,$13->breaklist);
						gencode(string("goto ") + to_string($7));
						current_scope = exit_scope();
						
			 		};
			 

for_declaration:  declaration  | expression_stmt ;

if_block:IF '(' expression ')' M stmt %prec LOWER_THAN_ELSE {
				backpatch($3->truelist,$5);
				$$ = new content_t();
				$$->nextlist = merge($3->falselist,$6->nextlist);
				$$->breaklist = $6->breaklist;
				$$->continuelist = $6->continuelist;
			}

		|IF '(' expression ')' M stmt ELSE N M stmt {
				backpatch($3->truelist,$5);
				backpatch($3->falselist,$9);

				$$ = new content_t();
				vector<int> temp = merge($6->nextlist,$8->nextlist);
				$$->nextlist = merge(temp,$10->nextlist);
				$$->breaklist = merge($10->breaklist,$6->breaklist);
				$$->continuelist = merge($10->continuelist,$6->continuelist);
			}	
    ;

while_block: WHILE M '(' expression ')' M {is_loop = 1;}  stmt {is_loop = 0;}
			{
				backpatch($8->nextlist,$2);
				backpatch($4->truelist,$6);
				backpatch($8->continuelist, $2);
				$$ = new content_t();
				$$->nextlist = merge($4->falselist,$8->breaklist);
				gencode(string("goto ") + to_string($2));
			}
		;

declaration: data_type  declaration_list ';' {is_declaration = 0;}			
			 | declaration_list ';'
			 | unary_expr ';'


declaration_list:  declaration_list COMMA sub_decl
					| sub_decl 
					;

sub_decl:	assignment_expr  
    		|
			identifier 	
    		|
			array_access
			;

/* This is because we can have empty expession statements inside for loops */
expression_stmt: data_type expression ';'	
				| expression ';' {
						$$ = new content_t(); 
						$$->truelist = $1->truelist; 
						$$->falselist = $1->falselist;
					}
				| ';'	{	$$ = new content_t();	}
    			;

expression: expression COMMA sub_expr {
					$$ = new content_t();
					$$->truelist = $3->truelist; 
					$$->falselist = $3->falselist;
				}
    		| sub_expr	{
					$$ = new content_t(); 
					$$->truelist = $1->truelist; 
					$$->falselist = $1->falselist;
				}
			;

sub_expr:
		sub_expr GREATERTHAN sub_expr	
			{
				type_check($1->data_type,$3->data_type,2);
				$$ = new content_t();
				gencode_rel($$, $1, $3, string(" > "));
			}
		| sub_expr LESSTHAN sub_expr
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

		| sub_expr NEQ sub_expr
			{
				type_check($1->data_type,$3->data_type,2);
				$$ = new content_t();
				gencode_rel($$, $1, $3, string(" != "));
			}

		| sub_expr GREATERTHANEQUAL sub_expr
			{
				type_check($1->data_type,$3->data_type,2);
				$$ = new content_t();
				gencode_rel($$, $1, $3, string(" >= "));
			}

		| sub_expr LESSTHANEQUAL sub_expr
			{
				type_check($1->data_type,$3->data_type,2);
				$$ = new content_t();
				gencode_rel($$, $1, $3, string(" <= "));
			}

		|sub_expr AND M sub_expr
			{
				type_check($1->data_type,$4->data_type,2);
				$$ = new content_t();
				$$->data_type = $1->data_type;
				backpatch($1->truelist,$3);
				$$->truelist = $4->truelist;
				$$->falselist = merge($1->falselist,$4->falselist);
			}

		|sub_expr OR M sub_expr
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
		 		$$->code = $1->code + *$2 + $3->addr;
				gencode($$->code);
		 		rhs = 0;
			}

    |lhs assign array_access
			{
				type_check($1->entry->data_type,$3->data_type,1);
	 			$$ = new content_t();
				$$->data_type = $3->data_type;
	 			$$->code = $1->code + *$2 + $3->code;
				gencode($$->code);
	 			rhs = 0;
			}

	|lhs assign unary_expr  
	        {
				type_check($1->entry->data_type,$3->data_type,1);
			 	$$ = new content_t();
				$$->data_type = $3->data_type;
			 	$$->code = $1->code + *$2 + $3->code;
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
			};


unary_expr: identifier INCREMENT	
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
	| array_access INCREMENT{
				$$ = new content_t();
				$$->data_type = $1->data_type;
				$$->code = $1->code+string("++");
				gencode($$->code);
	}
	| array_access DECREMENT{
				$$ = new content_t();
				$$->data_type = $1->data_type;
				$$->code = $1->code+string("--");
				gencode($$->code);
	}
	| INCREMENT array_access{
				$$ = new content_t();
				$$->data_type = $2->data_type;
				$$->code = $2->code+string("++");
				gencode($$->code);
	}
	| DECREMENT array_access{
				$$ = new content_t();
				$$->data_type = $2->data_type;
				$$->code = $2->code+string("--");
				gencode($$->code);
	};
	
	

lhs: identifier		{$$ = new content_t(); $$->entry = $1; $$->code = string($1->lexeme);}
   | array_access	{ $$ = new content_t(); $$=$1;}
	 ;

identifier: IDENTIFIER {
					if(is_array_index){
						// display_all();
						$1=search_recursive(yylval.lexi);
                      	if($1 == NULL) 
					  		yyerror("Variable not declared");
						
					}
                    else if(is_declaration && !rhs)
                    {	
						
						if(current_dtype == INT){
							size = 4;
						}else if(current_dtype == LONG_LONG){
							size = 8;
						}else if(current_dtype == CHAR){
							size = 1;
						}else if(current_dtype == SHORT){
							size = 1;
						}else if(current_dtype == LONG){
							size = 8;
						}
						string temp_lex;
						temp_lex.assign(yylval.lexi);
						// cout<<temp_lex<<endl;
						char temp = current_scope+'0';
						temp_lex+=temp;
						// cout<<temp_lex<<endl;
						// strcat(yylval.lexi, &temp);

						int n = temp_lex.length();
					
						// declaring character array
						char char_array[n + 1];
					
						// copying the contents of the
						// string to char array
						strcpy(char_array, temp_lex.c_str());

						$1=insert(SYMBOL_TABLE,char_array,INT_MAX,current_dtype, size);
						
						if($1 == NULL) 
							yyerror("Redeclaration of variable");
						
                    }
                    else
                    {	
						// display_all();
						$1=search_recursive(yylval.lexi);
                      	if($1 == NULL) 
					  		yyerror("Variable not declared");
                    }
					$$ = $1;
					
                }
    		 ;

assign: ASSIGN 		{rhs=1; $$ = new string(" = ");}
    |PLUSEQ 	{rhs=1; $$ = new string(" += ");}
    |MINUSEQ 	{rhs=1; $$ = new string(" -= ");}
    |MULEQ 	{rhs=1; $$ = new string(" *= ");}
    |DIVEQ 	{rhs=1; $$ = new string(" /= ");}
    |MODEQ 	{rhs=1; $$ = new string(" %= ");}
    ;

arithmetic_expr: arithmetic_expr ADDITION arithmetic_expr
					 {
						type_check($1->data_type,$3->data_type,0);
						$$ = new content_t();
						$$->data_type = $1->data_type;
						gencode_math($$, $1, $3, string(" + "));
					 }

			| arithmetic_expr MINUS arithmetic_expr
			  		 {
						type_check($1->data_type,$3->data_type,0);
						$$ = new content_t();
						$$->data_type = $1->data_type;
						gencode_math($$, $1, $3, string(" - "));
					 }

			| arithmetic_expr STAR arithmetic_expr
					 {
						type_check($1->data_type,$3->data_type,0);
						$$ = new content_t();
		 				$$->data_type = $1->data_type;
						gencode_math($$, $1, $3, string(" * "));
					 }

			| arithmetic_expr DIVISION arithmetic_expr
					 {
						type_check($1->data_type,$3->data_type,0);
						$$ = new content_t();
						$$->data_type = $1->data_type;
						gencode_math($$, $1, $3, string(" / "));
					 }

		    | arithmetic_expr MODULO arithmetic_expr
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

    		|MINUS arithmetic_expr %prec UMINUS	
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
			| array_access{
					
					$$ = new content_t();
					$$ = $1;
					$$->addr=$1->code;
			}
    		 ;

constant: INTEGER_LITERAL {$1->is_constant=1; $$ = $1;} | CHAR_LITERAL {$1->is_constant=1; $$ = $1;} | TRUE {$1->is_constant=1; $$ = $1;} | FALSE {$1->is_constant=1; $$ = $1;}; 			

array_access: identifier arr					
				{	
					$$ = new content_t();
					$$->data_type = $1->data_type;
					$$->code = string($1->lexeme)+$2->code;
					$$->entry = $1;
					if(is_declaration && !rhs){
						$1->size*=$2->array_dimension;
					}

					
				}

arr: arr '[' {is_array_index=1;} array_index {is_array_index=0;}']' {
			$$ = new content_t();
			if(!$4){
				exit(0);
			}

			if(is_declaration && !rhs)
			{			
						if(!$4->is_constant){
							yyerror("Size of Array should be an Integer Literal.");
							exit(0);
						}
						
						if($4->value <= 0)
							yyerror("size of array is not positive");
						else if($4->is_constant){
							$$->array_dimension = $1->array_dimension * $4->value;
						}
			}
			else if($4->is_constant)
			{
				if($4->value > $1->array_dimension)
					yyerror("Array index out of bound");
				if($4->value < 0)
					yyerror("Array index cannot be negative");
			}

			
			if($4->is_constant)
				$$->code = string($1->code) + string("[") + to_string($4->value) + string("]");
			else
				$$->code = string($1->code) + string("[") + string($4->lexeme) + string("]");
		}
		| 
		'[' {is_array_index=1;} array_index {is_array_index=0;} ']' {
			
			$$ = new content_t();

			if(!$3){
				exit(0);
			}

			if(is_declaration && !rhs)
					{
						if(!$3->is_constant){
							yyerror("Size of Array should be an Integer Literal.");
							exit(0);
						}
						if($3->value <= 0)
							yyerror("size of array is not positive");
						else if($3->is_constant)
							$$->array_dimension = $3->value;
			}
			else if($3->is_constant)
			{
				if($3->value < 0)
					yyerror("Array index cannot be negative");
			}
			
			
			if($3->is_constant)
				$$->code = string("[") + to_string($3->value) + string("]");
			else
				$$->code = string("[") + string($3->lexeme) + string("]");
		};

array_index: constant		{$$ = $1;}
		   | identifier		{$$ = $1;}
					 ;

M: 			{$$ = nextinstr;} ;

N:			{
				$$ = new content_t;
				$$->nextlist = {nextinstr};
				gencode("goto _");
			}
	;

%%

void gencode(string x) {
	std::string instruction;

	instruction = to_string(nextinstr) + string(": ") + x;
	ICG.push_back(instruction);
	nextinstr++;
}

void gencode_rel(content_t* & lhs, content_t* arg1, content_t* arg2, const string& op) {
	lhs->data_type = arg1->data_type;

	lhs->truelist = {nextinstr};
	lhs->falselist = {nextinstr + 1};

	std::string code;

	code = string("if ") + arg1->addr + op + arg2->addr + string(" goto _");
	gencode(code);

	code = string("goto _");
	gencode(code);
}

void gencode_math(content_t* & lhs, content_t* arg1, content_t* arg2, const string& op) {
	lhs->addr = "t" + to_string(temp_var_number);
	std::string expr = lhs->addr + string(" = ") + arg1->addr + op + arg2->addr;
	lhs->code = arg1->code + arg2->code + expr;

	temp_var_number++;

	gencode(expr);
}

void backpatch(vector<int>& v1, int number) {
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

vector<int> merge(vector<int>& v1, vector<int>& v2) {
	vector<int> concat;
	concat.reserve(v1.size() + v2.size());
	concat.insert(concat.end(), v1.begin(), v1.end());
	concat.insert(concat.end(), v2.begin(), v2.end());

	return concat;
}

void type_check(int left, int right, int flag) {
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

void displayICG() {
	ofstream outfile("ICG.code");

	for(int i=0; i<ICG.size();i++)
	outfile << ICG[i] <<endl;

	outfile << nextinstr << ": exit";

	outfile.close();
}

void printlist(vector<int> v) {
	for(auto it:v)
		cout<<it<<" ";
	cout<<"Next: "<<nextinstr<<endl;
}

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
	displayICG();
	fclose(yyin);
	return 0;
}

void yyerror(const char *msg)
{
	printf("Line no: %d Error message: %s Token: %s\n", yylineno, msg,yylval.lexi );
	// exit(0);
}
