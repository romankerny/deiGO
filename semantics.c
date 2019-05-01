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

int Valid_Octal(char * s)
{
    int i;

    for (i = 0; i < strlen(s); i++) {
        if (s[i] >= '8') return 0;
    }
    return 1;
}


char * get_Clean_Val(char *s) {

    int i, l = strlen(s);
    int a = 0;
    char * new_s = calloc(l, sizeof(char));
    int first_bracket = 0;
    
    for (i = 0; i < l; i++)
    {
        if(s[i] == '(')
        {
            first_bracket = i;
            break;
        }
    }
    for(i = first_bracket + 1; i < l-1; i++) {
        if(s[i] == ')') break;
        new_s[a++] = s[i]; 
    }
    return new_s;

}
char* get_op(char *op) {
    if (strcmp(op, "And") == 0)
        return "&&";
    if (strcmp(op, "Or") == 0)
        return "||";
    if (strcmp(op, "Lt") == 0)
        return "<";
    if (strcmp(op, "Gt") == 0)
        return ">";
    if (strcmp(op, "Eq") == 0)
        return "==";
    if (strcmp(op, "Ne") == 0)
        return "!=";
    if (strcmp(op, "Le") == 0)
        return "<=";
    if (strcmp(op, "Ge") == 0)
        return ">=";
    if (strcmp(op, "Add") == 0 || strcmp(op, "Plus") == 0)
        return "+";
    if (strcmp(op, "Sub") == 0 || strcmp(op, "Minus") == 0)
        return "-";
    if (strcmp(op, "Mul") == 0)
        return "*";
    if (strcmp(op, "Div") == 0)
        return "/";
    if (strcmp(op, "Mod") == 0)
        return "%";
    if (strcmp(op, "Not") == 0)
        return "!";
    if (strcmp(op, "Assign") == 0)
        return "=";

    // Unreacheable
    return "$";
}

int isIntlit(char * s) {
    int len = strlen(s); // garantir q não há erros de acesso de memória
    if(len >= 2 && s[0] == 'I' && s[1] == 'n') {
        return 1;
    }
    return 0;
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
            check_FuncHeader(aux->down);
        }
        aux = aux->right;
    }
    
    aux = prog->down;
    while (aux) {
        if (strcmp(aux->str, "FuncDecl") == 0) {

            n* FuncHeader = aux->down;
            n* FuncBody = FuncHeader->right;

            char *name = malloc(sizeof(char)*strlen(FuncHeader->down->str)); 
            sscanf(FuncHeader->down->str,"Id(%s)", name);
            name[strlen(name)-1] = '\0';

            Function *func = search_Function_by_name(name);
            check_FuncBody(FuncBody, func);
        
            free(name);
        }
        aux = aux->right;
    }
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
        aux->str = realloc(aux->str, strlen(aux->str) + 20);
        char * type = check_Call(aux, func);
        if(strcmp(type,"none") != 0)
            sprintf(aux->str, "%s - %s", aux->str, type);


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

    // find if all vars used
    n * aux2 = FuncBody->down;
    while(aux2)
    {
        if(strcmp(aux2->str, "VarDecl") == 0)
        {
            // 
            char * id = getCleanId(aux2->down->right->str);
            Function_element * f = search_Element(func, id);

            if(f->used == 0)
            {
                printf("Line %d, column %d: Symbol %s declared but never used\n", aux2->down->right->line, aux2->down->right->col, id);
            }
        }
        aux2 = aux2->right;
    }
    

}

Function * check_FuncHeader(n* FuncHeader)
{   
    n* FuncId = FuncHeader->down;
    n* FuncParams;
    n* ParamDecl;

    char type[50]= {0};
    char aux[512] = {0};
    char param_str[512] = {0};
    strcpy(param_str, "");
    int i = 0;

    char id[512] = {0};
    sscanf(FuncId->str,"Id(%s)", id);
    id[strlen(id)-1] = 0;

    Function * to_return = insert_Function(id);

    if(to_return == NULL) {
        printf("Line %d, column %d: Symbol %s already defined\n", FuncId->line, FuncId->col, id);
    }
    else
    {
        // we also need to check if there are no global variables with the same name

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
            
            strcpy(aux, ParamDecl->down->str);
            aux[0] = tolower(aux[0]);

            if (i == 0) 
            {

                strcat(param_str, aux);
            }
            else {
                strcat(param_str, ",");
                strcat(param_str, aux);
            }

            char param_id[512] = {0};
            sscanf(ParamDecl->down->right->str,"Id(%s)", param_id);
            param_id[strlen(param_id)-1] = '\0'; // tirar o )
            
            if(check_if_param_Already_Defined(to_return, param_id))
            {
                printf("Line %d, column %d: Symbol %s already defined\n", ParamDecl->down->right->line, ParamDecl->down->right->col, param_id);
            }
            
            insert_Func_element(param_id, aux,"param", to_return);
            ParamDecl = ParamDecl->right;
            i++;
        }

        strcat(param_str, ")");

        //char name_aux = strdup(to_return->name);
        char name_aux[512] = {0};
        strcpy(name_aux, to_return->name);
        //char * last = malloc(sizeof(char) * (strlen(to_return->name) + strlen(param_str) + strlen(name_aux)));
        char last[512] = {0};

        strcat(last, name_aux);
        strcat(last, param_str);
        to_return->name = strdup(last);

        insert_Global_element(id, type, param_str);

    }
    return to_return;
}


void check_Assign(n* Assign, Function *func) {

    Assign->str = realloc(Assign->str, sizeof(char)*(strlen(Assign->str) + 20));

    n* Id = Assign->down;
    Id->str = realloc(Id->str, sizeof(char)*(strlen(Id->str) + 20));

    n* Expr = Id->right;
    
    char* expr_type = check_Expr(Expr, func);

    char* name_id = malloc(sizeof(char) * strlen(Id->str));
    sscanf(Id->str, "Id(%s)", name_id);
    name_id[strlen(name_id)-1] = '\0';

    Function_element *element = search_Element(func, name_id);
    Global_element *gelement = search_Global(name_id, 0);

    if (element == NULL && gelement == NULL) {
        printf("Line %d, column %d: Cannot find symbol %s\n", Id->line, Id->col, name_id);
        printf("Line %d, column %d: Operator %s cannot be applied to types undef, undef\n", Assign->line, Assign->col, get_op(Assign->str));
        strcat(Id->str, " - undef");
        strcat(Assign->str, " - undef");
    } else if (element){
        set_as_Used(element); 

        sprintf(Id->str, "%s - %s", Id->str, element->type);
        if (strcmp(element->type, expr_type) == 0) {
            sprintf(Assign->str, "%s - %s", Assign->str, element->type);
        }
        else if(strcmp(element->type, "float32") == 0 && isIntlit(Expr->str)) 
        {
            sprintf(Assign->str, "%s - float32", Assign->str);
        }
        else {
            printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", Assign->line, Assign->col, get_op(Assign->str), element->type, expr_type);
            strcat(Assign->str, " - undef");
        }
    } else {

        if (gelement->params == NULL) {

            sprintf(Id->str, "%s - %s", Id->str, gelement->type);

            if (strcmp(gelement->type, expr_type) == 0) {
                sprintf(Assign->str, "%s - %s", Assign->str, gelement->type);
            }
            else if(strcmp(gelement->type, "float32") == 0 && isIntlit(Expr->str)) 
            {
                sprintf(Assign->str, "%s - float32", Assign->str);
            }
            else {
                printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", Assign->line, Assign->col, get_op(Assign->str), gelement->type, expr_type);
                strcat(Assign->str, " - undef");
            }
        } else {
            printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", Assign->line, Assign->col, get_op(Assign->str), "undeff", expr_type);
            strcat(Assign->str, " - undef");
        }
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


void check_Return(n* Return, Function *func) 
{

    char * func_type        = get_Func_Type(func);
    char * expression_type  = check_Expr(Return->down, func);


    if(expression_type == NULL) {
        if(!(strcmp(func_type, "none") == 0)) {
            printf("Line %d, column %d: Incompatible type void in return statement\n", Return->line, Return->col);
        }
    }
    else 
    {
        if(!(strcmp(func_type, expression_type) == 0)) 
        {
            printf("Line %d, column %d: Incompatible type %s in return statement\n", Return->down->line, Return->down->col, expression_type);
        }
    }
 
}

char * check_Call(n* Call, Function *func) 
{

    n * id_func = Call->down;
    n * params = id_func->right;

    char expr_type[1024] = {0};
    strcpy(expr_type, "(");
    
    int i = 0;
    while(params)
    {
        if (i == 0) {
            strcat(expr_type, check_Expr(params, func));
        } else {
            strcat(expr_type, ",");
            strcat(expr_type, check_Expr(params, func));
        }
        i++;
        params = params->right;
    }
    strcat(expr_type, ")");

    char *id = getCleanId(id_func->str);
    id = realloc(id, sizeof(char) * (strlen(id)+strlen(expr_type)*2)); 
    strcat(id, expr_type);

    Function *called_func = search_Function(id);
    if (called_func == NULL) {
        id_func->str = realloc(id_func->str, sizeof(char)*(strlen(id_func->str)+ strlen(expr_type) + 20));
        printf("Line %d, column %d: Cannot find symbol %s\n", id_func->line, id_func->col, id);
        sprintf(id_func->str, "%s - %s", id_func->str, expr_type);
        return "undef";
    } else {
        Global_element *called_global = search_Global(getCleanId(id_func->str), 1); // tem de existir nesta fase
        id_func->str = realloc(id_func->str, sizeof(char)*((strlen(id_func->str)+strlen(called_global->params)) + 20));
        sprintf(id_func->str, "%s - %s", id_func->str, called_global->params);
        return called_global->type;
    }
}

void check_Print(n* Print, Function *func) {

    n* Expr_or_StrLit = Print->down;
    char first = Expr_or_StrLit->str[0];
    char second = Expr_or_StrLit->str[1];

    if (first == 'S' && second == 't') {
        
        Expr_or_StrLit->str = realloc(Expr_or_StrLit->str, sizeof(char)*(strlen(Expr_or_StrLit->str) + 20));
        strcat(Expr_or_StrLit->str, " - string");

    } else {
        char expr_type[512] = {0};
        strcpy(expr_type, check_Expr(Expr_or_StrLit, func));

        if (strcmp(expr_type, "undef") == 0) {
            printf("Line %d, column %d: Incompatible type %s in fmt.Println statement\n",Expr_or_StrLit->line, Expr_or_StrLit->col, expr_type);
        }
    }

}
void check_ParseArgs(n* ParseArgs, Function *func) {

    // Get children
    n* IdVar = ParseArgs->down;
    n* Expr = IdVar->right;

    // Prepare for annotate
    ParseArgs->str = realloc(ParseArgs->str, sizeof(char)* (strlen(ParseArgs->str) + 20));
    IdVar->str = realloc(IdVar->str, sizeof(char)* (strlen(IdVar->str) + 20));

    // Remove Id()
    char* name_IdVar = malloc(sizeof(char) * strlen(IdVar->str));
    sscanf(IdVar->str, "Id(%s)", name_IdVar);
    name_IdVar[strlen(name_IdVar)-1] = '\0';

    // Get elements
    Function_element *var_el = search_Element(func, name_IdVar);
    Global_element *var_gel = search_Global(name_IdVar, 0);

    char *var_type;

    if (var_el == NULL && var_gel == NULL) {
        printf("Line %d, column %d: Cannot find symbol %s\n", IdVar->line, IdVar->col, name_IdVar);
    } else if (var_el) {
        sprintf(IdVar->str, "%s - %s", IdVar->str, var_el->type);
        var_type = var_el->type;
    } else {

        if (var_gel->params == NULL) {
            sprintf(IdVar->str, "%s - %s", IdVar->str, var_gel->type);
            var_type = var_gel->type;
        }
    }

    char *index_type = check_Expr(Expr, func);

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
    
    char first    = Expr->str[0];
    char second   = Expr->str[1];

    
    if (first == 'I' && second == 'n')
    {   
        char seventh  = Expr->str[7];
        char eigth    = Expr->str[8];

        Expr->str = realloc(Expr->str, sizeof(char) * (strlen(Expr->str) + 20));

        if(seventh == '0' && eigth != 'x' && eigth != 'X')
        {
            char * octal = get_Clean_Val(Expr->str);
            
            if(!Valid_Octal(octal))
            {
                printf("Line %d, column %d: Invalid octal constant: %s\n", Expr->line, Expr->col, octal);
                strcat(Expr->str, " - undef");
                return "undef";
            }
            else 
            {
                strcat(Expr->str, " - int");
                return "int";
            }
        }
        else
        {
            strcat(Expr->str, " - int");
            return "int";
        }


    } 
    else if(first == 'R')
    {
        Expr->str = realloc(Expr->str, sizeof(char) * (strlen(Expr->str) + 20));
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
        Global_element *gel   = search_Global(id, 0);

        Expr->str = realloc(Expr->str, strlen(Expr->str) + 20);

        if (el == NULL && gel == NULL) 
        {
            printf("Line %d, column %d: Cannot find symbol %s\n", Expr->line, Expr->col, id);
            strcat(Expr->str, " - undef");
            return "undef";
        }
        else if (el)
        {
            set_as_Used(el); 
            sprintf(Expr->str, "%s - %s", Expr->str, el->type);
            return el->type;
        } else {
            if (gel->params == NULL) {
                sprintf(Expr->str, "%s - %s", Expr->str, gel->type);
                return gel->type;
            } else {
                strcat(Expr->str, " - undef");
                return "undef";
            }
        }

        
    }
    else if(first == 'C' && second == 'a')
    {
        Expr->str   = realloc(Expr->str, strlen(Expr->str) + 20);
        char *type = check_Call(Expr, func);

        if(strcmp(type,"none") != 0)
            sprintf(Expr->str, "%s - %s", Expr->str, type);
        return type;
    } 
    else {
        char *t1 = check_Expr(Expr->down,        func);
        char *t2 = check_Expr(Expr->down->right, func);

        Expr->str = realloc(Expr->str, strlen(Expr->str) + 20);
        
        // compare

        // GE GT LT LE - int int - float float
        if(strcmp(Expr->str, "Lt") == 0 || strcmp(Expr->str, "Gt") == 0 || strcmp(Expr->str, "Le") == 0  || strcmp(Expr->str, "Ge") == 0)
        {
            if((strcmp(t1, "int") == 0 && strcmp(t2,"int") == 0) || (strcmp(t1, "float32") == 0 && strcmp(t2,"float32") == 0) || (strcmp(t1, "string") == 0 && strcmp(t2,"string") == 0)) 
            {
                sprintf(Expr->str, "%s - bool", Expr->str);
                return "bool";
            }
            else if((strcmp(t1, "float32") == 0 && isIntlit(Expr->down->right->str)) || ((strcmp(t2, "float32") == 0 && isIntlit(Expr->down->str))))
            {
                sprintf(Expr->str, "%s - bool", Expr->str);
                return "bool";
            }
            else
            {   
                printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", Expr->line, Expr->col, get_op(Expr->str), t1, t2);
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
                printf("Line %d, column %d: Operator %s cannot be applied to type %s\n", Expr->line, Expr->col, get_op(Expr->str), t1);
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
                printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", Expr->line, Expr->col, get_op(Expr->str), t1, t2);
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
            else if((strcmp(t1, "float32") == 0 && isIntlit(Expr->down->right->str)) || ((strcmp(t2, "float32") == 0 && isIntlit(Expr->down->str))))
            {
                sprintf(Expr->str, "%s - bool", Expr->str);
                return "bool";
            }
            else
            {
                printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", Expr->line, Expr->col, get_op(Expr->str), t1, t2);
                sprintf(Expr->str, "%s - undef", Expr->str);
                return "undef";
            }
            

        }        // contas
        
        // - / * % int e int, float e float
        else if(strcmp(Expr->str, "Sub") == 0 || strcmp(Expr->str, "Div") == 0 || strcmp(Expr->str, "Mul") == 0) {

            if ((strcmp(t1, "int") == 0 && strcmp(t2, "int") == 0) || (strcmp(t1, "float32") == 0 && strcmp(t2, "float32") == 0)) {
                sprintf(Expr->str, "%s - %s", Expr->str, t1);
                return t1;
            }
            else if((strcmp(t1, "float32") == 0 && isIntlit(Expr->down->right->str)) || ((strcmp(t2, "float32") == 0 && isIntlit(Expr->down->str))))
            {
                sprintf(Expr->str, "%s - float32", Expr->str);
                return "float32";
            }
            else {
                printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", Expr->line, Expr->col, get_op(Expr->str), t1, t2);
                sprintf(Expr->str, "%s - undef", Expr->str);
                return "undef";
            }

        } 
        else if(strcmp(Expr->str, "Mod") == 0)
        {
            if ((strcmp(t1, "int") == 0 && strcmp(t2, "int") == 0)) {
                sprintf(Expr->str, "%s - %s", Expr->str, t1);
                return t1;
            } 
            else 
            {
                printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", Expr->line, Expr->col, get_op(Expr->str), t1, t2);
                sprintf(Expr->str, "%s - undef", Expr->str);
                return "undef";
            }
        }

        // + int e int, float e float, string e string
        else if(strcmp(Expr->str, "Add") == 0) {
    
             if ((strcmp(t1, "int") == 0 && strcmp(t2, "int") == 0) || (strcmp(t1, "float32") == 0 && strcmp(t2, "float32") == 0) || (strcmp(t1, "string") == 0 && strcmp(t2, "string") == 0)) {
                sprintf(Expr->str, "%s - %s", Expr->str, t1);
                return t1;
            }
            else if((strcmp(t1, "float32") == 0 && isIntlit(Expr->down->right->str)) || ((strcmp(t2, "float32") == 0 && isIntlit(Expr->down->str))))
            {
                sprintf(Expr->str, "%s - float32", Expr->str);
                return "float32";
            }        
            else {
                printf("Line %d, column %d: Operator %s cannot be applied to types %s, %s\n", Expr->line, Expr->col, get_op(Expr->str), t1, t2);
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
                printf("Line %d, column %d: Operator %s cannot be applied to type %s\n", Expr->line, Expr->col, get_op(Expr->str), t1);
                sprintf(Expr->str, "%s - undef", Expr->str);
                return "undef";
            }
        }
    }
    // Unreachable
    return "unreachable";
}