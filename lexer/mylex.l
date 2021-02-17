%{
#include "lexer.h"	
%}
%option nounput yylineno



JAVA_LETTER         		[A-Za-z_$]
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

/* BINARY LITERAL */
BinaryDigit                  [01]
BinaryDigitOrUnderscore      {BinaryDigit}|_
BinaryDigitsAndUnderscores   {BinaryDigitOrUnderscore}*
BinaryDigits                 {BinaryDigit}|({BinaryDigit}{BinaryDigitsAndUnderscores}?{BinaryDigit})
BinaryNumeral                (0b{BinaryDigits})|(0B{BinaryDigits})
BinaryIntegerLiteral         ({BinaryNumeral})({IntegerTypeSuffix}?)

/* FLOATING POINT LITERAL */
Sign                          [+-]
FloatTypeSuffix               [fFdD]
ExponentIndicator             [eE]
SignedInteger                 {Sign}?{Digits}

ExponentPart                  {ExponentIndicator}{SignedInteger}
DecimalFloatingPointLiteral   ({Digits}[.]{Digits}?{ExponentPart}?{FloatTypeSuffix}?)|([.]{Digits}{ExponentPart}?{FloatTypeSuffix}?)|({Digits}{ExponentPart}{FloatTypeSuffix}?)|({Digits}{ExponentPart}?{FloatTypeSuffix})
   
BinaryExponentIndicator       [pP]
BinaryExponent                {BinaryExponentIndicator}{SignedInteger}  
HexSignificand                {HexNumeral}|{HexNumeral}.|(0(x|X){HexDigits}?.{HexDigits}) 
HexadecimalFloatingPointLiteral {HexSignificand}{BinaryExponent}{FloatTypeSuffix}?

FloatingPointLiteral            {DecimalFloatingPointLiteral}|{HexadecimalFloatingPointLiteral}

/* Escape Sequence */
ZeroToThree  					[0-3]

OctalEscape  					(\\{OctalDigit})|(\\{OctalDigit}{OctalDigit})|(\\{ZeroToThree}{OctalDigit}{OctalDigit})
        
EscapeSequence  				 (\\b)|(\\t)|(\\n)|(\\r)|((\\)(\"))|((\\)(\'))|((\\)(\\))|({OctalEscape})                
  









%%
"{"|"}"|"("|")"|";"|","|"."|"["|"]"           					{printf("\n\n TOKEN_NAME: Separator\t\t\t VALUE: %s",yytext); return -1;}
"/*"([^*]|"*"+[^/*])*"*/"               						{return -1;}
"//"(.)*                       									{return -1;}
"abstract"|"continue"|"for"|"new"|"while"						{printf("\n\n TOKEN_NAME: Keyword\t\t\t VALUE: %s",yytext); return -1;}
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
"null"                          								{printf("\n\n TOKEN_NAME: NULL Literal\t\t VALUE: %s",yytext);return NULL_LITERAL;}
{BinaryIntegerLiteral}          								{printf("\n\n TOKEN_NAME: Integer Literal\t\t VALUE: %s",yytext); return INTEGER_LITERAL;}
{OctalIntegerLiteral}           								{printf("\n\n TOKEN_NAME: Integer Literal\t\t VALUE: %s",yytext); return INTEGER_LITERAL;}
{HexIntegerLiteral}             								{printf("\n\n TOKEN_NAME: Integer Literal\t\t VALUE: %s",yytext); return INTEGER_LITERAL;}
{DecimalIntegerLiteral}         								{printf("\n\n TOKEN_NAME: Integer Literal\t\t VALUE: %s",yytext); return INTEGER_LITERAL;}
{FloatingPointLiteral}          								{printf("\n\n TOKEN_NAME: Float Literal\t\t VALUE: %s",yytext); return FLOAT_LITERAL;}
"true"|"false"                  								{printf("\n\n TOKEN_NAME: Boolean Literal\t\t VALUE: %s",yytext); return BOOLEAN_LITERAL;}

\"([^\\\"]|{EscapeSequence})*+\"                         		{printf("\n\n TOKEN_NAME: String Literal\t\t VALUE: %s",yytext); return STRING_LITERAL;}
\'([^\\\']|{EscapeSequence})\'                          		{printf("\n\n TOKEN_NAME: Character Literal\t\t VALUE: %s",yytext); return CHAR_LITERAL;}
{JAVA_LETTER}({JAVA_LETTER}|{DIGIT})*   						{printf("\n\n TOKEN_NAME: Identifier\t\t\t VALUE: %s",yytext); return IDENTIFIER;}
\n                               								{return -1;}
.                                								{return -1;};
%%
int yywrap(void){
	return 1;
}

