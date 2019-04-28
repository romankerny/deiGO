#include "structures.h"
#include "semantics.h"
#include "symtab.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>


char * getCleanId(char * IdCidC)
{
    char * id = malloc(sizeof(char) * strlen(IdCidC));
    sscanf(IdCidC,"Id(%s)", id);
    int len = strlen(id);
    id[len-1] = '\0';
    return id;
}


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

    Assign->str = realloc(Assign->str, sizeof(char)*(strlen(Assign->str)+10));

    n* Id = Assign->down;
    Id->str = realloc(Id->str, sizeof(char)*(strlen(Id->str) + 10));

    n* Expr = Id->right;
    
    char* expr_type = check_Expr(Expr, func);

    char* name_id = malloc(sizeof(char) * strlen(Id->str));
    sscanf(Id->str, "Id(%s)", name_id);
    name_id[strlen(name_id)-1] = '\0';

    Function_element *element = search_Element(func, name_id);
    Global_element *gelement = search_Global(name_id);

    if (element == NULL && gelement == NULL) {
        printf("Line %d, column %d: Cannot find symbol %s\n", Id->line, Id->col, name_id);
        strcat(Id->str, " - undef");
        strcat(Assign->str, " - undef");
    } else if (element){
        sprintf(Id->str, "%s - %s", Id->str, element->type);

        if (strcmp(element->type, expr_type) == 0)
            sprintf(Assign->str, "%s - %s", Assign->str, element->type);
        else
            strcat(Assign->str, " - undef");

    } else {
        sprintf(Id->str, "%s - %s", Id->str, gelement->type);

        if (strcmp(gelement->type, expr_type) == 0)
            sprintf(Assign->str, "%s - %s", Assign->str, gelement->type);
        else
            strcat(Assign->str, " - undef");
    }

}

void check_Block(n* Block, Function *func) {

    if (Block == NULL)
        return;

    n * aux = Block->down;
    while(aux)
    {
        check_Statement(aux, func);
        aux = aux->right;
    }
}


void check_If(n* If, Function *func) {

    n* Expr = If->down;
    n* Block1 = Expr->right;
    n* Block2 = Block1->right;
    
    char* type = check_Expr(Expr, func);

    if(strcmp(type, "bool")) {
        printf("Line %d, column %d: Incompatible type %s in if statement\n", Expr->line, Expr->col, type);
    }

    check_Block(Block1, func);
    check_Block(Block2, func);
}

void check_For(n* For, Function *func) {

    n * down_for  = For->down;



    if(strcmp(down_for->str, "Block") == 0)
    {
        check_Block(down_for, func);
    }
    else
    {
        char * type = check_Expr(down_for, func);
        if(strcmp(type, "bool")) 
        {
            printf("Line %d, column %d: Incompatible type %s in if statement\n", down_for->line, down_for->col, type);
        }
        check_Block(down_for->right, func);
        
    }

}
void check_Return(n* Return, Function *func) {
    check_Expr(Return->down, func);

}

char * check_Call(n* Call, Function *func) 
{

    char * func_params;
    n * id_func = Call->down;
    n * aux = id_func->right;

    

    char * id = getCleanId(id_func->str);

    Global_element * global_aux = search_Global(id); // tem de existir nesta fase
    func_params = global_aux->params;
    
    while(aux)
    {
        check_Expr(aux, func);
        aux = aux->right;
    }

    
    
    sprintf(id_func->str, "%s - %s", id_func->str, func_params);
    return global_aux->type; // tipo do return

}

void check_Print(n* Print, Function *func) {

    n* Expr_or_StrLit = Print->down;
    char first = Expr_or_StrLit->str[0];
    char second = Expr_or_StrLit->str[1];

    if (first == 'S' && second == 't') {
        /*
        Expr_or_StrLit->str = realloc(Expr_or_StrLit->str, sizeof(char)*(strlen(Expr_or_StrLit->str) + 10));
        strcat(Expr_or_StrLit->str, " - string");*/

    } else {
        check_Expr(Expr_or_StrLit, func);
    }

}
void check_ParseArgs(n* ParseArgs, Function *func) {

    // Get children
    n* IdVar = ParseArgs->down;
    n* IdIndex = IdVar->right;

    // Prepare for annotate
    ParseArgs->str = realloc(ParseArgs->str, sizeof(char)* (strlen(ParseArgs->str) + 10));
    IdVar->str = realloc(IdVar->str, sizeof(char)* (strlen(IdVar->str) + 10));
    IdIndex->str = realloc(IdIndex->str, sizeof(char)* (strlen(IdIndex->str) + 10));

    // Remove Id()
    char* name_IdVar = malloc(sizeof(char) * strlen(IdVar->str));
    sscanf(IdVar->str, "Id(%s)", name_IdVar);
    name_IdVar[strlen(name_IdVar)-1] = '\0';

    char* name_IdIndex = malloc(sizeof(char) * strlen(IdIndex->str));
    sscanf(IdIndex->str, "Id(%s)", name_IdIndex);
    name_IdIndex[strlen(name_IdIndex)-1] = '\0';

    // Get elements
    Function_element *var_el = search_Element(func, name_IdVar);
    Global_element *var_gel = search_Global(name_IdVar);

    char *var_type;

    if (var_el == NULL && var_gel == NULL) {
        printf("Line %d, column %d: Cannot find symbol %s\n", IdVar->line, IdVar->col, name_IdVar);
    } else if (var_el) {
        sprintf(IdVar->str, "%s - %s", IdVar->str, var_el->type);
        var_type = var_el->type;
    } else {
        sprintf(IdVar->str, "%s - %s", IdVar->str, var_gel->type);
        var_type = var_gel->type;
    }

    Function_element *index_el = search_Element(func, name_IdIndex);
    Global_element *index_gel = search_Global(name_IdIndex);

    char *index_type;

    if (index_el == NULL && index_gel == NULL) {
        printf("Line %d, column %d: Cannot find symbol %s\n", IdIndex->line, IdIndex->col, name_IdIndex);
    } else if (index_el) {
        sprintf(IdIndex->str, "%s - %s", IdIndex->str, index_el->type);
        index_type = index_el->type;
    } else {
        sprintf(IdIndex->str, "%s - %s", IdIndex->str, index_gel->type);
        index_type = index_gel->type;
    }

     if (strcmp(var_type, "int") == 0 && strcmp(index_type, "int") == 0) {
         strcat(ParseArgs->str, " - int");
     } else {
        strcat(ParseArgs->str, " - undef");
        printf("Line %d, column %d: Operator strconv.Atoi cannot be applied to types %s, %s\n", ParseArgs->line, ParseArgs->col, var_type, index_type);
     }

}

char * check_Expr(n * Expr, Function * func) {

    if (Expr == NULL)
        return NULL;
    
    char first  = Expr->str[0];
    char second = Expr->str[1];


    if (first == 'I' && second == 'n')
    {   
        Expr->str = realloc(Expr->str, strlen(Expr->str) + 10);
        strcat(Expr->str, " - int");
        return "int";
    } 
    else if(first == 'R')
    {
        Expr->str = realloc(Expr->str, strlen(Expr->str) + 10);
        strcat(Expr->str, " - float32");
        return "float32";

    } 
    else if(first == 'I' && second == 'd')
    {
        char * id = malloc(sizeof(char) * strlen(Expr->str));
        sscanf(Expr->str,"Id(%s)", id);
        int len = strlen(id);
        id[len-1] = '\0';

        Function_element * el = search_Element(func, id);
        Global_element *gel = search_Global(id);

        Expr->str = realloc(Expr->str, strlen(Expr->str) + 10);

        if (el == NULL && gel == NULL) {
            printf("Line %d, column %d: Cannot find symbol %s\n", Expr->line, Expr->col, id);
            strcat(Expr->str, " - undef");
            return "undef";
        }
        else if (el)
        {
            sprintf(Expr->str, "%s - %s", Expr->str, el->type);
            return el->type;
        } else {
            sprintf(Expr->str, "%s - %s", Expr->str, gel->type);
            return gel->type;
        }

        
    }
    else if(first == 'C' && second == 'a')
    {

        char * type = check_Call(Expr, func);
        sprintf(Expr->str, "%s - %s", Expr->str, type);
        return type;
    } 
    else {
        char *t1 = check_Expr(Expr->down,        func);
        char *t2 = check_Expr(Expr->down->right, func);

        Expr->str = realloc(Expr->str, strlen(Expr->str) + 10);
        
        // compare

        // GE GT LT LE - int int - float float
        if(strcmp(Expr->str, "Lt") == 0 || strcmp(Expr->str, "Gt") == 0 || strcmp(Expr->str, "Le") == 0  || strcmp(Expr->str, "Ge") == 0)
        {
            if((strcmp(t1, "int") == 0 && strcmp(t2,"int") == 0) || (strcmp(t1, "float32") == 0 && strcmp(t2,"float32") == 0)) 
            {
                sprintf(Expr->str, "%s - bool", Expr->str);
                return "bool";
            } 
            else
            {   
                sprintf(Expr->str, "%s - undef", Expr->str);
                return "undef";
            }

        }  // Not - bool
        else if(strcmp(Expr->str,"Not") == 0)
        {
            if(strcmp(t1,"bool") == 0 && t2 == NULL)
            {
                sprintf(Expr->str, "%s - bool", Expr->str);
                return "bool";
            }
            else
            {
                sprintf(Expr->str, "%s - undef", Expr->str);
                return "undef";
            }
        } // And e Or : bool - bool
        else if(strcmp(Expr->str, "And") == 0 || strcmp(Expr->str, "Or") == 0)
        {
            if(strcmp(t1,"bool") == 0 && strcmp(t2, "bool") == 0)
            {
                sprintf(Expr->str, "%s - bool", Expr->str);
                return "bool";
            }
            else
            {
                sprintf(Expr->str, "%s - undef", Expr->str);
                return "undef";
            }
            
        } // == !=  int e int, float e float, bool e bool, string e string
        else if(strcmp(Expr->str, "Eq") == 0 || strcmp(Expr->str, "Ne") == 0)
        {
            if(strcmp(t1, t2) == 0)
            {
                sprintf(Expr->str, "%s - bool", Expr->str);
                return "bool";
            }
            else
            {
                sprintf(Expr->str, "%s - undef", Expr->str);
                return "undef";
            }
            

        }        // contas
        
        // - / * % int e int, float e float
        else if(strcmp(Expr->str, "Sub") == 0 || strcmp(Expr->str, "Div") == 0 || strcmp(Expr->str, "Mul") == 0 || strcmp(Expr->str, "Mod") == 0 ) {

            if ((strcmp(t1, "int") == 0 && strcmp(t2, "int") == 0) || (strcmp(t1, "float32") == 0 && strcmp(t2, "float32") == 0)) {
                sprintf(Expr->str, "%s - %s", Expr->str, t1);
                return t1;
            } else {
                sprintf(Expr->str, "%s - undef", Expr->str);
                return "undef";
            }

        }

        // + int e int, float e float, string e string
        else if(strcmp(Expr->str, "Add") == 0) {
             if ((strcmp(t1, "int") == 0 && strcmp(t2, "int") == 0) || (strcmp(t1, "float32") == 0 && strcmp(t2, "float32") == 0)
             || (strcmp(t1, "string") == 0 && strcmp(t2, "string") == 0)) {
                sprintf(Expr->str, "%s - %s", Expr->str, t1);
                return t1;
            } else {
                sprintf(Expr->str, "%s - undef", Expr->str);
                return "undef";
            }
        }


        // +a -a     t2 == null e int, ou float
        else if (strcmp(Expr->str, "Plus") == 0 || strcmp(Expr->str, "Minus") == 0) {
             if (strcmp(t1, "int") == 0 || strcmp(t1, "float32") == 0 ) {
                sprintf(Expr->str, "%s - %s", Expr->str, t1);
                return t1;
            } else {
                sprintf(Expr->str, "%s - undef", Expr->str);
                return "undef";
            }
        }
    }
    // Unreachable
    return "unreachable";
}