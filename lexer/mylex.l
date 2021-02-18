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

"continue"|"for"|"while"										{printf("\n\n TOKEN_NAME: Keyword\t\t\t VALUE: %s",yytext); return -1;}
"switch"|"assert"|"default"|"goto"|"package"					{printf("\n\n TOKEN_NAME: Keyword\t\t\t VALUE: %s",yytext); return -1;}
"synchronized"|"boolean"|"do"|"if"|"private"					{printf("\n\n TOKEN_NAME: Keyword\t\t\t VALUE: %s",yytext); return -1;}
"this"|"break"|"double"|"implements"|"protected" 				{printf("\n\n TOKEN_NAME: Keyword\t\t\t VALUE: %s",yytext); return -1;}
"throw"|"byte"|"else"|"import"|"public" 						{printf("\n\n TOKEN_NAME: Keyword\t\t\t VALUE: %s",yytext); return -1;}
"throws"|"case"|"enum"|"instanceof"|"return" 					{printf("\n\n TOKEN_NAME: Keyword\t\t\t VALUE: %s",yytext); return -1;}
"transient"|"catch"|"extends"|"int"|"short"						{printf("\n\n TOKEN_NAME: Keyword\t\t\t VALUE: %s",yytext); return -1;}
"try"|"char"|"final"|"interface"|"static" 						{printf("\n\n TOKEN_NAME: Keyword\t\t\t VALUE: %s",yytext); return -1;}
"void"|"class"|"finally"|"long"|"strictfp" 						{printf("\n\n TOKEN_NAME: Keyword\t\t\t VALUE: %s",yytext); return -1;}
"volatile"|"const"|"float"|"native"|"super" 					{printf("\n\n TOKEN_NAME: Keyword\t\t\t VALUE: %s",yytext); return -1;}


"++"|"--"|"~"|"!"|"*"|"/"|"%"|"+"|"-"                           {printf("\n\n TOKEN_NAME: Arithmetic operator\t VALUE: %s",yytext); return -1;}
">"|"<"|"<="|">="|"instanceof"|"=="|"!="   						{printf("\n\n TOKEN_NAME: Relational operator\t VALUE: %s",yytext); return -1;}
">>"|"<<"|">>>"|"&"|"^"|"|"                						{printf("\n\n TOKEN_NAME: Arithmetic operator\t VALUE: %s",yytext); return -1;}
"&&"|"||"|"?"|":"                            					{printf("\n\n TOKEN_NAME: Conditional operator\t VALUE: %s",yytext); return -1;}
"="|"+="|"-="|"*="|"/="|"%="|"&="|"^="|"|="|"<<="|">>="|">>>="  {printf("\n\n TOKEN_NAME: Assignment operator\t VALUE: %s",yytext); return -1;}

"NULL"                          								{return NULL_LITERAL;}

{OctalIntegerLiteral}|{HexIntegerLiteral}|{DecimalIntegerLiteral} {return INTEGER_LITERAL;}

"true"															{return TRUE;}
"false"                  										{return FALSE;}

\"([^\\\"]|{EscapeSequence})*+\"                         		{return STRING_LITERAL}
{CHARACTER_CONSTANT}                          					{return CHAR_LITERAL;}
{C_LETTER}({C_LETTER}|{DIGIT})*   								{printf("\n\n TOKEN_NAME: Identifier\t\t\t VALUE: %s",yytext); return IDENTIFIER;}
\n|\t                               							{}
.                                								{}
%%
int yywrap(void){
	return 1;
}

