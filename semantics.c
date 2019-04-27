#include "structures.h"
#include "semantics.h"
#include "symtab.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>



void check_VarDeclGlobal(n* VarType) {
    
    n* VarId = VarType->right;
    char * id = malloc(sizeof(char) * strlen(VarId->str));
    sscanf(VarId->str,"Id(%s)", id);
    int len = strlen(id);
    id[len-1] = '\0';

    char * type = strdup(VarType->str);
    type[0] = tolower(type[0]);

    if (insert_Global_element(id, type, NULL) == NULL)
    {
        printf("Line %d, column %d: Symbol %s already defined\n", VarId->line, VarId->col, id);
    }
}

void check_VarDeclFunc(n * VarType, Function * func) {
    n* VarId = VarType->right;
    char * id = malloc(sizeof(char) * strlen(VarId->str));
    sscanf(VarId->str,"Id(%s)", id);
    int len = strlen(id);
    id[len-1] = '\0';

    char * type = strdup(VarType->str);
    type[0] = tolower(type[0]);

    if (insert_Func_element(id, type, NULL, func) == NULL)
    {
        printf("Line %d, column %d: Symbol %s already defined\n", VarId->line, VarId->col, id);
    }

}

void check_program(n* prog)
{
    n * aux = prog->down;
    
    while(aux){
    
        if(strcmp(aux->str, "VarDecl") == 0)
        {
            check_VarDeclGlobal(aux->down);

        } else if(strcmp(aux->str, "FuncDecl") == 0)
        {
            check_FuncDecl(aux);
        }
        aux = aux->right;
    }
}

void check_FuncDecl(n* FuncDecl)
{
    Function * func;

    func = check_FuncHeader(FuncDecl->down);
    check_FuncBody(FuncDecl->down->right, func);

}

void check_FuncBody(n * FuncBody, Function * func)
{
    n * aux = FuncBody->down; 
    while(aux)
    {
        if(strcmp(aux->str, "VarDecl") == 0) {
            check_VarDeclFunc(aux->down, func);
        }


        aux = aux->right;
    }

}

Function * check_FuncHeader(n* FuncHeader)
{   
    n* FuncId = FuncHeader->down;
    n* FuncParams;
    n* ParamDecl;

    char * type = NULL, *aux;
    char param_str [1024] = "";
    int i = 0;



    char * id = malloc(sizeof(char) * strlen(FuncId->str));
    
    sscanf(FuncId->str,"Id(%s)", id);
    int len = strlen(id);
    id[len-1] = '\0'; // tirar o )


    Function * to_return = insert_Function(id);
    
    if (strcmp(FuncId->right->str, "FuncParams") == 0)
    {
        
        type = strdup("none");
        FuncParams = FuncId->right;
    }
    else
    {
        type = strdup(FuncId->right->str);
        type[0] = tolower(type[0]);
        FuncParams = FuncId->right->right;
    }
    
    

    printf("%s\n", type);
    insert_Func_element("return", type, NULL, to_return);
    
    ParamDecl = FuncParams->down;
    strcat(param_str, "(");
    


    while(ParamDecl)
    {
        aux = strdup("\0");
        aux = strdup(ParamDecl->down->str);
        aux[0] = tolower(aux[0]);

        if (i == 0) {
            
            strcat(param_str, aux);
        }
        else {
            strcat(param_str, ",");
            strcat(param_str, aux);
            
        }

        char * param_id = malloc(sizeof(char) * strlen(ParamDecl->down->right->str));
        sscanf(ParamDecl->down->right->str,"Id(%s)", param_id);
        param_id[strlen(param_id)-1] = '\0';


        insert_Func_element(param_id, aux,"param", to_return);
        ParamDecl = ParamDecl->right;
        i++;
    }

    strcat(param_str, ")");
    param_str[strlen(param_str)] = '\0';

    strcat(to_return->name, param_str);
    
    insert_Global_element(id, type, param_str);

    
    return to_return;
}
