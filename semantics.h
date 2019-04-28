#include "structures.h"
#include "symtab.h"

void check_program(n* prog);
void check_VarDecl(n* VarType);
void check_FuncDecl(n* FuncDecl);
Function * check_FuncHeader(n* FuncHeader);
void check_FuncBody(n * FuncBody, Function * func);
void check_Statement(n * aux, Function * func);
char * check_Expr(n * Expr, Function * func);


void check_Assign(n* Assign, Function *func);
void check_Block(n* Block, Function *func);
void check_If(n* If, Function *func);
void check_For(n* For, Function *func);
void check_Return(n* Return, Function *func);
char * check_Call(n* Call, Function *func);
void check_Print(n* Print, Function *func);
void check_ParseArgs(n* ParseArgs, Function *func);
