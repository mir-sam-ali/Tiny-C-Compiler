/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     IDENTIFIER = 258,
     INTEGER_LITERAL = 259,
     STRING_LITERAL = 260,
     CHAR_LITERAL = 261,
     AND = 262,
     OR = 263,
     LESSTHANEQUAL = 264,
     GREATERTHANEQUAL = 265,
     EQ = 266,
     NEQ = 267,
     AMPERSAND = 268,
     MULEQ = 269,
     DIVEQ = 270,
     MODEQ = 271,
     PLUSEQ = 272,
     MINUSEQ = 273,
     INCREMENT = 274,
     DECREMENT = 275,
     SHORT = 276,
     INT = 277,
     LONG = 278,
     LONG_LONG = 279,
     SIGNED = 280,
     UNSIGNED = 281,
     CONST = 282,
     CHAR = 283,
     BOOLEAN = 284,
     VOID = 285,
     IF = 286,
     FOR = 287,
     WHILE = 288,
     CONTINUE = 289,
     BREAK = 290,
     RETURN = 291,
     CASE = 292,
     DEFAULT = 293,
     DO = 294,
     ELSE = 295,
     SWITCH = 296,
     STAR = 297,
     ADDITION = 298,
     MINUS = 299,
     NEGATION = 300,
     EXCLAIMATION = 301,
     DIVISION = 302,
     MODULO = 303,
     SHIFTLEFT = 304,
     SHIFTRIGHT = 305,
     LESSTHAN = 306,
     GREATERTHAN = 307,
     BITXOR = 308,
     BITOR = 309,
     QUESTION = 310,
     ASSIGN = 311,
     SHIFTLEQ = 312,
     SHIFTREQ = 313,
     BITANDEQ = 314,
     BITXOREQ = 315,
     BITOREQ = 316,
     HASH = 317,
     TRUE = 318,
     FALSE = 319,
     PRINTF = 320,
     SCANF = 321,
     GETS = 322,
     PUTS = 323,
     SIZEOF = 324,
     LOOP = 325,
     SUM = 326,
     MAX = 327,
     MIN = 328,
     COMMA = 329,
     FULL_STOP = 330,
     OPEN_SQUARE = 331,
     CLOSE_SQUARE = 332,
     COLON = 333,
     LOGICAL_AND = 334,
     UMINUS = 335,
     LOWER_THAN_ELSE = 336
   };
#endif
/* Tokens.  */
#define IDENTIFIER 258
#define INTEGER_LITERAL 259
#define STRING_LITERAL 260
#define CHAR_LITERAL 261
#define AND 262
#define OR 263
#define LESSTHANEQUAL 264
#define GREATERTHANEQUAL 265
#define EQ 266
#define NEQ 267
#define AMPERSAND 268
#define MULEQ 269
#define DIVEQ 270
#define MODEQ 271
#define PLUSEQ 272
#define MINUSEQ 273
#define INCREMENT 274
#define DECREMENT 275
#define SHORT 276
#define INT 277
#define LONG 278
#define LONG_LONG 279
#define SIGNED 280
#define UNSIGNED 281
#define CONST 282
#define CHAR 283
#define BOOLEAN 284
#define VOID 285
#define IF 286
#define FOR 287
#define WHILE 288
#define CONTINUE 289
#define BREAK 290
#define RETURN 291
#define CASE 292
#define DEFAULT 293
#define DO 294
#define ELSE 295
#define SWITCH 296
#define STAR 297
#define ADDITION 298
#define MINUS 299
#define NEGATION 300
#define EXCLAIMATION 301
#define DIVISION 302
#define MODULO 303
#define SHIFTLEFT 304
#define SHIFTRIGHT 305
#define LESSTHAN 306
#define GREATERTHAN 307
#define BITXOR 308
#define BITOR 309
#define QUESTION 310
#define ASSIGN 311
#define SHIFTLEQ 312
#define SHIFTREQ 313
#define BITANDEQ 314
#define BITXOREQ 315
#define BITOREQ 316
#define HASH 317
#define TRUE 318
#define FALSE 319
#define PRINTF 320
#define SCANF 321
#define GETS 322
#define PUTS 323
#define SIZEOF 324
#define LOOP 325
#define SUM 326
#define MAX 327
#define MIN 328
#define COMMA 329
#define FULL_STOP 330
#define OPEN_SQUARE 331
#define CLOSE_SQUARE 332
#define COLON 333
#define LOGICAL_AND 334
#define UMINUS 335
#define LOWER_THAN_ELSE 336




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;

