%{
#include "lexer.h"	
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
"{"																{return OPEN_CURLY;}
"}"																{return CLOSE_CURLY;}
"("																{return OPEN_PARANTHESIS;}
")"																{return CLOSE_PARANTHESIS;}
";"																{return SEMI_COLON;}
","																{return COMMA;}
"."																{return FULL_STOP;}
"["																{return OPEN_SQUARE;}
"]"																{return CLOSE_SQUARE;}
":"																{return COLON;}
"/*"([^*]|"*"+[^/*])*"*/"               						{}
"//"(.)*                       									{}




"auto"						{return AUTO;}
"break"						{return BREAK;}
"case"						{return CASE;}											
"char"						{return CHAR;}							
"const"						{return CONST;}						
"continue"					{return CONTINUE;}							
"default"					{return DEFAULT;}	
"do"						{return DO;}
"double"					{return DOUBLE;}	
"else"						{return ELSE;}
"enum"						{return ENUM;}
"extern"					{return EXTERN;}
"float"						{return FLOAT;}
"for"						{return FOR;}
"goto"						{return GOTO;}
"if"						{return IF;}
"inline"					{return INLINE;}	
"int"						{return INT;}
"long"						{return LONG;}
"register"					{return REGISTER;}
"restrict"					{return RESTRICT;}
"return"					{return RETURN;}
"short"						{return SHORT;}
"signed"					{return SIGNED;}
"sizeof"					{return SIZEOF;}
"static"					{return STATIC;}
"struct"					{return STRUCT;}
"switch"					{return SWITCH;}
"typedef"					{return TYPEDEF;}
"union"						{return UNION;}
"unsigned"					{return UNSIGNED;}
"void"						{return VOID;}
"volatile"					{return VOLATILE;}
"while"						{return WHILE;}


"->"						{ return ARROW;}
"++"						{ return INCREMENT;}
"--"						{ return DECREMENT;}
"&"							{ return AMPERSAND;}
"*"							{ return STAR;}
"+"							{ return ADDITION;}
"-"							{ return SUBTRACTION;}
"~"							{ return NEGATION;}
"!"							{ return EXCLAIMATION;}
"/" 						{return DIVISION;}
"%" 						{return MODULO;}
"<<" 						{return SHIFTLEFT;}
">>" 						{return SHIFTRIGHT;}
"<" 						{return LESSTHAN;}
">" 						{return GREATERTHAN;}
"<=" 						{return LESSTHANEQUAL;}
">=" 						{return GREATERTHANEQUAL;}
"==" 						{return EQUAL;}
"!=" 						{return NOTEQUAL;}
"^" 						{return BITXOR;}
"|" 						{return BITOR;}
"&&" 						{return AND;}
"||" 						{return OR;}
"?" 						{return QUESTION;}


"..." 						{return DOTS;}
"=" 						{return ASSIGN;}
"*=" 						{return MULEQ;}
"/=" 						{return DIVEQ;}
"%=" 						{return MODEQ;}
"+=" 						{return PLUSEQ;}
"-=" 						{return MINUSEQ;}
"<<=" 						{return SHIFTLEQ;}
">>=" 						{return SHIFTREQ;}
"&=" 						{return BITANDEQ;}
"^=" 						{return BITXOREQ;}
"|=" 						{return BITOREQ;}
"#" 						{return HASH;}




{OctalIntegerLiteral}|{HexIntegerLiteral}|{DecimalIntegerLiteral} {return INTEGER_LITERAL;}

"NULL"                          								{return NULL_LITERAL;}
"true"															{return TRUE;}
"false"                  										{return FALSE;}

"printf"					{return PRINTF;}
"scanf"						{return SCANF;}
"gets"						{return GETS;}
"puts"						{return PUTS;}
"sizeof"					{return SIZEOF;}
"loop"						{return LOOP;}
"sum"						{return SUM;}
"max"						{return MAX;}	
"min"						{return MIN;}


\"([^\\\"]|{EscapeSequence})*+\"                         		{return STRING_LITERAL}
{CHARACTER_CONSTANT}                          					{return CHAR_LITERAL;}
{C_LETTER}({C_LETTER}|{DIGIT})*   								{printf("\n\n TOKEN_NAME: Identifier\t\t\t VALUE: %s",yytext); return IDENTIFIER;}
\n|\t                               							{}
.                                								{}
%%
int yywrap(void){
	return 1;
}

