%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h" 
%}
alpha [A-Za-z]
digit [0-9]

%%
"if"            return IF;
"then"          return THEN;
"else"          return ELSE;
">="            return GE;
"<="            return LE;
"=="            return EQ;
"!="            return NE;
">>"            return RS; 
{alpha}+    	{strcpy(yylval.string, yytext); return ID; }
{digit}+ 		{yylval.number= atoi(yytext); return NUMBER;}
";"				return ';'; 

[ \t] ;      /* ignore white space */

"$"		{ return 0; }
.  		{ return yytext[0]; }

%%
