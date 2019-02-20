#!/bin/sh

flex gocompiler.l
clang-3.9 -o gocompiler lex.yy.c
