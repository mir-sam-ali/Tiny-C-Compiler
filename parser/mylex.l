%{

#include <stdlib.h>
#include <stdio.h>
#include <limits.h>

#include "y.tab.h"

entry_t** constant_table;

int cmnt_strt = 0;

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
"{"																{ return yytext[0];}
"}"																{ return yytext[0];}
"("																{ return yytext[0];}
")"																{ return yytext[0];}
";"																{ return yytext[0];}
","																{ return COMMA;}
"."																{ return FULL_STOP;}
"["																{ return yytext[0];}
"]"																{ return yytext[0];}
":"																{ return COLON;}
"/*"([^*]|"*"+[^/*])*"*/"               						{}
"//"(.)*                       									{}





"break"						{ return BREAK;}
"case"						{ return CASE;}											
"char"						{ return CHAR;}							
"const"						{ return CONST;}						
"continue"					{ return CONTINUE;}							
"default"					{ return DEFAULT;}	
"do"						{ return DO;}

"else"						{ return ELSE;}


"for"						{ return FOR;}

"if"						{ return IF;}

"int"						{ return INT;}
"long long"					{ return LONG_LONG;}
"long"						{ return LONG;}
"string"					{return STRING;}

"return"					{ return RETURN;}
"short"						{ return SHORT;}
"signed"					{ return SIGNED;}
"boolean"					{ return BOOLEAN;}


"switch"					{ return SWITCH;}


"unsigned"					{ return UNSIGNED;}
"void"						{ return VOID;}

"while"						{ return WHILE;}



"++"						{  return INCREMENT;}
"--"						{  return DECREMENT;}
"&"							{  return AMPERSAND;}
"*"							{  return STAR;}
"+"							{  return ADDITION;}
"-"							{  return MINUS;}
"~"							{  return NEGATION;}
"!"							{  return EXCLAIMATION;}
"/" 						{ return DIVISION;}
"%" 						{ return MODULO;}
"<<" 						{ return SHIFTLEFT;}
">>" 						{ return SHIFTRIGHT;}
"<" 						{ return LESSTHAN;}
">" 						{ return GREATERTHAN;}
"<=" 						{ return LESSTHANEQUAL;}
">=" 						{ return GREATERTHANEQUAL;}
"==" 						{ return EQ;}
"!=" 						{ return NEQ;}
"^" 						{ return BITXOR;}
"|" 						{ return BITOR;}
"&&" 						{ return AND;}
"||" 						{ return OR;}
"?" 						{ return QUESTION;}
"=" 						{ return ASSIGN;}
"*=" 						{ return MULEQ;}
"/=" 						{ return DIVEQ;}
"%=" 						{ return MODEQ;}
"+=" 						{ return PLUSEQ;}
"-=" 						{ return MINUSEQ;}
"<<=" 						{ return SHIFTLEQ;}
">>=" 						{ return SHIFTREQ;}
"&=" 						{ return BITANDEQ;}
"^=" 						{ return BITXOREQ;}
"|=" 						{ return BITOREQ;}
"#" 						{ return HASH;}




{OctalIntegerLiteral}|{HexIntegerLiteral}|{DecimalIntegerLiteral} { yylval.entry = insert(constant_table,yytext,atoi(yytext),INT,4); return INTEGER_LITERAL;}


"true"															{ yylval.entry = insert(constant_table,yytext,1,BOOLEAN,1); return TRUE;}
"false"                  										{ yylval.entry = insert(constant_table,yytext,1,BOOLEAN,1); return FALSE;}

"printf"					{ return PRINTF;}
"scanf"						{ return SCANF;}
"gets"						{ return GETS;}
"puts"						{ return PUTS;}
"sizeof"					{ return SIZEOF;}
"loop"						{ return LOOP;}
"sum"						{ return SUM;}
"max"						{ return MAX;}	
"min"						{ return MIN;}


\"([^\\\"]|{EscapeSequence})*+\"                         		{ return STRING_LITERAL;}
{CHARACTER_CONSTANT}                          					{ yylval.entry = insert(constant_table,yytext,yytext[1],CHAR,1); return CHAR_LITERAL;}
{C_LETTER}({C_LETTER}|{DIGIT})*   								{ strcpy(yylval.lexi, yytext); return IDENTIFIER;}
\n|\t                               							{}
.                                								{}
%%
int yywrap(void){
	return 1;
}

