#include "structures.h"
#include "semantics.h"
#include "symtab.h"
#include <stdio.h>
#include <string.h>



int check_VarDecl(char * name, char * type) {

    if (insert_Global_element(name, type, NULL) == NULL)
    {
        // printf("Line <linha>, column <coluna>:Symbol < token > already defined\n");
        return 0;
    }

    return 1;
}

void check_program(n* prog)
{
    n * aux = prog->down;
    
    while(aux){
    
        if(strcmp(aux->str, "VarDecl") == 0)
        {
            check_VarDecl(aux->down->right->str, aux->down->str);

        } else if(strcmp(aux->str, "FuncDecl") == 0)
        {

        }
        aux = aux->right;
    }
}

