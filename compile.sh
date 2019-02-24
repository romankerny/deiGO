#!/bin/sh

flex gocompiler.l

clang-3.9 -Wall -Wno-unused-function -o gocompiler lex.yy.c
