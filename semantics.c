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

void check_VarDeclFunc(n * VarDecl, Function * func) {

    n* VarType = VarDecl->down;

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

void check_Statement(n * aux, Function * func)
{   
    if(strcmp(aux->str, "Assign") == 0) {
        check_Assign(aux, func);

    } else if(strcmp(aux->str, "Block") == 0) {
        check_Block(aux, func);

    } else if(strcmp(aux->str, "If") == 0) {
        check_If(aux, func);

    } else if(strcmp(aux->str, "For") == 0) {
        check_For(aux, func);

    } else if(strcmp(aux->str, "Return") == 0) {
        check_Return(aux, func);

    } else if(strcmp(aux->str, "Call") == 0) {
        check_Call(aux, func);

    } else if(strcmp(aux->str, "Print") == 0) {
        check_Print(aux, func);

    } else if(strcmp(aux->str, "ParseArgs") == 0) {
        check_ParseArgs(aux, func);
    }
}

void check_FuncBody(n * FuncBody, Function * func)
{
    n * aux = FuncBody->down; 
    while(aux)
    {
        if(strcmp(aux->str, "VarDecl") == 0) {
            check_VarDeclFunc(aux, func);
        }
        else
        {
            check_Statement(aux, func);
        }
        
        aux = aux->right;
    }

}

Function * check_FuncHeader(n* FuncHeader)
{   
    n* FuncId = FuncHeader->down;
    n* FuncParams;
    n* ParamDecl;

    char type[50], *aux;
    char param_str [1024] = "";
    int i = 0;



    char * id = malloc(sizeof(char) * strlen(FuncId->str));
    
    sscanf(FuncId->str,"Id(%s)", id);
    int len = strlen(id);
    id[len-1] = '\0'; // tirar o )


    Function * to_return = insert_Function(id);
    
    if (strcmp(FuncId->right->str, "FuncParams") == 0)
    {
        
        strcpy(type ,"none");
        FuncParams = FuncId->right;
    }
    else
    {
        strcpy(type ,strdup(FuncId->right->str));
        type[0] = tolower(type[0]);
        FuncParams = FuncId->right->right;
    }
    
    
    insert_Func_element("return", type, NULL, to_return);
    
    ParamDecl = FuncParams->down;
    strcat(param_str, "(");



    while(ParamDecl)
    {
        // aux = strdup("\0");
        aux = strdup(ParamDecl->down->str);
        aux[0] = tolower(aux[0]);

        if (i == 0) 
        {
            
            strcat(param_str, aux);
        }
        else {
            strcat(param_str, ",");
            strcat(param_str, aux);
        }

        char * param_id = malloc(sizeof(char) * strlen(ParamDecl->down->right->str));
        sscanf(ParamDecl->down->right->str,"Id(%s)", param_id);
        param_id[strlen(param_id)-1] = '\0'; // tirar o )
        


        insert_Func_element(param_id, aux,"param", to_return);
        ParamDecl = ParamDecl->right;
        i++;
    }

    strcat(param_str, ")");

    char * last = malloc(sizeof(char) * (strlen(to_return->name) + strlen(param_str)));
    char * name_aux = strdup(to_return->name);
    strcat(last, name_aux);
    strcat(last, param_str);
    to_return->name = strdup(last);

    insert_Global_element(id, type, param_str);

    
    return to_return;
}


void check_Assign(n* Assign, Function *func) {

    n* Id = Assign->down;
    n* Expr = Id->right;

    char* name_id = malloc(sizeof(char) * strlen(Id->str));
    sscanf(Id->str, "Id(%s)", name_id);
    name_id[strlen(name_id)-1] = '\0';

    Function_element *element = searh_Element(func, name_id);
    if (element == NULL) {
        printf("Line %d, column %d: Cannot find symbol %s\n", Id->line, Id->col, name_id);
    }

}

void check_Block(n* Block, Function *func) {
    n * aux = Block->down;

    while(aux)
    {
        check_Statement(aux, func);
        aux = aux->right;
    }
}

void check_If(n* If, Function *func) {

    
}
void check_For(n* For, Function *func) {

}
void check_Return(n* Return, Function *func) {

}
void check_Call(n* Call, Function *func) {

}
void check_Print(n* Print, Function *func) {

}
void check_ParseArgs(n* ParseArgs, Function *func) {

}
