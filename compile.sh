#!/bin/sh

flex gocompiler.l
yacc -d -v gocompiler.y
clang-3.9 -Wall -Wno-unused-function -o gocompiler y.tab.c lex.yy.c
