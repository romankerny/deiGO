#include "structures.h"
#include "semantics.h"
#include "symtab.h"
#include <stdio.h>
#include <string.h>

void check_program(n* prog)
{
    n * aux;
    
    for (aux = prog->down; aux->right; aux = aux->right)
    {
        if(strcmp(aux->str, "VarDecl") == 0)
        {
            insert_Global_element(aux->down->right->str, aux->down->str, NULL);

        } else if(strcmp(aux->str, "FuncDecl") == 0)
        {

        }
    }
}