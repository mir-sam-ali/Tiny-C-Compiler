%{
//#include "lexer.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"	
%}
%option nounput yylineno



C_LETTER         		[A-Za-z_$]
DIGIT 	                    [0-9]


/* DECIMAL LITERAL */
IntegerTypeSuffix   		[lL]
NON_ZERO_DIGIT              [1-9]
Underscores                 [_]+
DigitOrUnderscore           {DIGIT}|[_]
DigitsAndUnderscores        {DigitOrUnderscore}*
Digits                      {DIGIT}|({DIGIT}({DigitsAndUnderscores}?)({DIGIT}))
DecimalNumeral              0|(({NON_ZERO_DIGIT})({Digits}?))|({NON_ZERO_DIGIT})({Underscores})({Digits})
DecimalIntegerLiteral       ({DecimalNumeral})({IntegerTypeSuffix}?)

/* HEXADECIMAL LITERAL */
HexDigit                    [0-9A-Fa-f]
HexDigitOrUnderscore        {HexDigit}|[_]
HexDigitsAndUnderscores     {HexDigitOrUnderscore}*
HexDigits                   {HexDigit}|({HexDigit}{HexDigitsAndUnderscores}?{HexDigit})
HexNumeral                  (0x{HexDigits})|(0X{HexDigits})
HexIntegerLiteral           ({HexNumeral})({IntegerTypeSuffix}?)

/* OCTAL LITERAL */
OctalDigit                  [0-7]
OctalDigitOrUnderscore      {OctalDigit}|_
OctalDigitsAndUnderscores   {OctalDigitOrUnderscore}*
OctalDigits                 {OctalDigit}|({OctalDigit}{OctalDigitsAndUnderscores}?{OctalDigit})   
OctalNumeral                (0{OctalDigits})|(0{Underscores}{OctalDigits})
OctalIntegerLiteral         ({OctalNumeral})({IntegerTypeSuffix}?)


/* FLOATING POINT LITERAL */

/* Sign                          [+-]

/*FloatTypeSuffix               [fFdD]
/*ExponentIndicator             [eE]
/*SignedInteger                 {Sign}?{Digits}
/*
/*ExponentPart                  {ExponentIndicator}{SignedInteger}
/*DecimalFloatingPointLiteral   ({Digits}[.]{Digits}?{ExponentPart}?{FloatTypeSuffix}?)|([.]{Digits}{ExponentPart}?{FloatTypeSuffix}?)|({Digits}{ExponentPart}{FloatTypeSuffix}?)|({Digits}{ExponentPart}?{FloatTypeSuffix})
/*   
/*BinaryExponentIndicator       [pP]
/*BinaryExponent                {BinaryExponentIndicator}{SignedInteger}  
/*HexSignificand                {HexNumeral}|{HexNumeral}.|(0(x|X){HexDigits}?.{HexDigits}) 
/*HexadecimalFloatingPointLiteral {HexSignificand}{BinaryExponent}{FloatTypeSuffix}?
/*
/*FloatingPointLiteral            {DecimalFloatingPointLiteral}|{HexadecimalFloatingPointLiteral}



/* Escape Sequence */
ZeroToThree  					[0-3]

OctalEscape  					(\\{OctalDigit})|(\\{OctalDigit}{OctalDigit})|(\\{ZeroToThree}{OctalDigit}{OctalDigit})
        
EscapeSequence  				 (\\b)|(\\t)|(\\n)|(\\r)|((\\)(\"))|((\\)(\'))|((\\)(\\))|({OctalEscape})                
  


ESCAPE_SEQUENCE				[\\'\\"\\?\\\\\\a\\b\\f\\n\\r\\t\\v]
C_CHAR 						{ESCAPE_SEQUENCE}|[^("\'"|"\\"|"\n")]
C_CHAR_SEQUENCE				{C_CHAR}+
CHARACTER_CONSTANT			'{C_CHAR_SEQUENCE}'






%%
"{"																{ printf("\n%s\n",yytext); }
"}"																{ printf("\n%s\n",yytext); }
"("																{ printf("\n%s\n",yytext); }
")"																{ printf("\n%s\n",yytext); }
";"																{ printf("\n%s\n",yytext); }
","																{ printf("\n%s\n",yytext); return COMMA;}
"."																{ printf("\n%s\n",yytext); return FULL_STOP;}
"["																{ printf("\n%s\n",yytext); }
"]"																{ printf("\n%s\n",yytext); }
":"																{ printf("\n%s\n",yytext); return COLON;}
"/*"([^*]|"*"+[^/*])*"*/"               						{}
"//"(.)*                       									{}





"break"						{ printf("\n%s\n",yytext); return BREAK;}
"case"						{ printf("\n%s\n",yytext); return CASE;}											
"char"						{ printf("\n%s\n",yytext); return CHAR;}							
"const"						{ printf("\n%s\n",yytext); return CONST;}						
"continue"					{ printf("\n%s\n",yytext); return CONTINUE;}							
"default"					{ printf("\n%s\n",yytext); return DEFAULT;}	
"do"						{ printf("\n%s\n",yytext); return DO;}

"else"						{ printf("\n%s\n",yytext); return ELSE;}


"for"						{ printf("\n%s\n",yytext); return FOR;}

"if"						{ printf("\n%s\n",yytext); return IF;}

"int"						{ printf("\n%s\n",yytext); return INT;}
"long long"					{ printf("\n%s\n",yytext); return LONG_LONG;}
"long"						{ printf("\n%s\n",yytext); return LONG;}


"return"					{ printf("\n%s\n",yytext); return RETURN;}
"short"						{ printf("\n%s\n",yytext); return SHORT;}
"signed"					{ printf("\n%s\n",yytext); return SIGNED;}
"boolean"					{ printf("\n%s\n",yytext); return BOOLEAN;}


"switch"					{ printf("\n%s\n",yytext); return SWITCH;}


"unsigned"					{ printf("\n%s\n",yytext); return UNSIGNED;}
"void"						{ printf("\n%s\n",yytext); return VOID;}

"while"						{ printf("\n%s\n",yytext); return WHILE;}



"++"						{  printf("\n%s\n",yytext); return INCREMENT;}
"--"						{  printf("\n%s\n",yytext); return DECREMENT;}
"&"							{  printf("\n%s\n",yytext); return AMPERSAND;}
"*"							{  printf("\n%s\n",yytext); return STAR;}
"+"							{  printf("\n%s\n",yytext); return ADDITION;}
"-"							{  printf("\n%s\n",yytext); return MINUS;}
"~"							{  printf("\n%s\n",yytext); return NEGATION;}
"!"							{  printf("\n%s\n",yytext); return EXCLAIMATION;}
"/" 						{ printf("\n%s\n",yytext); return DIVISION;}
"%" 						{ printf("\n%s\n",yytext); return MODULO;}
"<<" 						{ printf("\n%s\n",yytext); return SHIFTLEFT;}
">>" 						{ printf("\n%s\n",yytext); return SHIFTRIGHT;}
"<" 						{ printf("\n%s\n",yytext); return LESSTHAN;}
">" 						{ printf("\n%s\n",yytext); return GREATERTHAN;}
"<=" 						{ printf("\n%s\n",yytext); return LESSTHANEQUAL;}
">=" 						{ printf("\n%s\n",yytext); return GREATERTHANEQUAL;}
"==" 						{ printf("\n%s\n",yytext); return EQ;}
"!=" 						{ printf("\n%s\n",yytext); return NEQ;}
"^" 						{ printf("\n%s\n",yytext); return BITXOR;}
"|" 						{ printf("\n%s\n",yytext); return BITOR;}
"&&" 						{ printf("\n%s\n",yytext); return AND;}
"||" 						{ printf("\n%s\n",yytext); return OR;}
"?" 						{ printf("\n%s\n",yytext); return QUESTION;}
"=" 						{ printf("\n%s\n",yytext); return ASSIGN;}
"*=" 						{ printf("\n%s\n",yytext); return MULEQ;}
"/=" 						{ printf("\n%s\n",yytext); return DIVEQ;}
"%=" 						{ printf("\n%s\n",yytext); return MODEQ;}
"+=" 						{ printf("\n%s\n",yytext); return PLUSEQ;}
"-=" 						{ printf("\n%s\n",yytext); return MINUSEQ;}
"<<=" 						{ printf("\n%s\n",yytext); return SHIFTLEQ;}
">>=" 						{ printf("\n%s\n",yytext); return SHIFTREQ;}
"&=" 						{ printf("\n%s\n",yytext); return BITANDEQ;}
"^=" 						{ printf("\n%s\n",yytext); return BITXOREQ;}
"|=" 						{ printf("\n%s\n",yytext); return BITOREQ;}
"#" 						{ printf("\n%s\n",yytext); return HASH;}




{OctalIntegerLiteral}|{HexIntegerLiteral}|{DecimalIntegerLiteral} { printf("\n%s\n",yytext); return INTEGER_LITERAL;}


"true"															{ printf("\n%s\n",yytext); return TRUE;}
"false"                  										{ printf("\n%s\n",yytext); return FALSE;}

"printf"					{ printf("\n%s\n",yytext); return PRINTF;}
"scanf"						{ printf("\n%s\n",yytext); return SCANF;}
"gets"						{ printf("\n%s\n",yytext); return GETS;}
"puts"						{ printf("\n%s\n",yytext); return PUTS;}
"sizeof"					{ printf("\n%s\n",yytext); return SIZEOF;}
"loop"						{ printf("\n%s\n",yytext); return LOOP;}
"sum"						{ printf("\n%s\n",yytext); return SUM;}
"max"						{ printf("\n%s\n",yytext); return MAX;}	
"min"						{ printf("\n%s\n",yytext); return MIN;}


\"([^\\\"]|{EscapeSequence})*+\"                         		{ printf("\n%s\n",yytext); return STRING_LITERAL;}
{CHARACTER_CONSTANT}                          					{ printf("\n%s\n",yytext); return CHAR_LITERAL;}
{C_LETTER}({C_LETTER}|{DIGIT})*   								{printf("\n\n TOKEN_NAME: Identifier\t\t\t VALUE: %s",yytext); return IDENTIFIER;}
\n|\t                               							{}
.                                								{}
%%
int yywrap(void){
	return 1;
}

