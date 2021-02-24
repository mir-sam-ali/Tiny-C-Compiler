
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
%}

alpha [A-Za-z]
digit [0-9]
und [_]

%%
[ \t] ;
\n	    {yylineno++;}
"{"	    { return '{';}
"}"	    { return '}';}
";"	     {   return(';'); }
","	     {   return(','); }
":"	     {   return(':'); }
"="	     {   return('='); }
"("	     {   return('('); }
")"	     {   return(')'); }
("[") 	     {   return('['); }
("]")        {   return(']'); }
"."	     {   return('.'); }
"&"	     {   return('&'); }
"!"	     {   return('!'); }
"~"	     {   return('~'); }
"-"	     {   return('-'); }
"+"	     {   return('+'); }
"*"	     {   return('*'); }
"/"	     {   return('/'); }
"%"	     {   return('%'); }
"<"	     {   return('<'); }
">"	     {   return('>'); }
"^"	     {   return('^'); }
"|"	     {   return('|'); }
"?"	     {   return('?'); }

{alpha}({alpha}|{digit}|{und})* { return ID;}
{digit}+	{return NUM;}
{digit}+\.{digit}+ 	{ return REAL;}
.	;
%%