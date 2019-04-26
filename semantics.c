#include "structures.h"
#include "semantics.h"
#include "symtab.h"
#include <stdio.h>
#include <string.h>



void check_VarDecl(n* VarType) {
    
    n* VarId = VarType->right;

    if (insert_Global_element(VarId->str, VarType->str, NULL) == NULL)
    {
        printf("Line %d, column %d: Symbol %s already defined\n", VarId->line, VarId->col, VarId->str);
    }
}

void check_program(n* prog)
{
    n * aux = prog->down;
    
    while(aux){
    
        if(strcmp(aux->str, "VarDecl") == 0)
        {
            check_VarDecl(aux->down);

        } else if(strcmp(aux->str, "FuncDecl") == 0)
        {
            check_FuncDecl(aux);
        }
        aux = aux->right;
    }
}

void check_FuncDecl(n* FuncDecl)
{
    check_FuncHeader(FuncDecl->down);
}

void check_FuncHeader(n* FuncHeader)
{   
    //n* FuncId = FuncHeader->down;
    /*
    if (strcmp(FuncId->right->str, "FuncParams") == 0)
        insert_Global_element(FuncHeader->down->str, "none", "()");*/


}
