#include "structures.h"
#include "symtab.h"

void check_program(n* prog);
void check_VarDecl(n* VarType);
void check_FuncDecl(n* FuncDecl);
Function * check_FuncHeader(n* FuncHeader);
void check_FuncBody(n * FuncBody, Function * func);