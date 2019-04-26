#!/bin/sh

flex gocompiler.l
yacc -d -v gocompiler.y
clang-3.9 -Wall -Wno-unused-function -o gocompiler lex.yy.c y.tab.c functions.c symtab.c semantics.c