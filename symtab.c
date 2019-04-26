#include "symtab.h"
#include<stdlib.h>
#include<string.h>
#include<stdio.h>

extern Global_element* global;
extern Function *funcs;

Function * insert_Function(char *name) {
    
    Function * aux;
    Function * new_Function = malloc(sizeof(Function));

    new_Function->down = NULL;
    new_Function->name = NULL;
    new_Function->next = NULL;

    for (aux = funcs; aux->down; aux = aux->down);
    aux->down = new_Function;

    new_Function->name = strdup(name);

    return new_Function;
}

Params * insert_Param(char * type, Params * head)
{
    Params * aux;
    Params * new_param = malloc(sizeof(Params));
    new_param->type = strdup(type);
    new_param->next = NULL;

    if(head == NULL) return new_param;

    for (aux = head; aux->next; aux = aux->next);
    aux->next = new_param;

    return head;
}

Function_element * insert_Func_element(char * name, char * type, char * param, Function * func) {

    Function_element * aux;
    Function_element * new_func_el = malloc(sizeof(Function_element));
    new_func_el->name  = NULL;
    new_func_el->next  = NULL;
    new_func_el->param = NULL;
    new_func_el->type  = NULL;

    for (aux = func->next; aux->next; aux = aux->next)
    {
        if(strcmp(aux->name, name) == 0) return NULL;
    }
    
    aux->next = new_func_el;

    new_func_el->name  = name;
    new_func_el->param = param;
    new_func_el->type  = type;

    return new_func_el;
    
}

Global_element * insert_Global_element(char * name, char * type, Params * params) {
    
    Global_element * aux;
    Global_element * new_global_el = malloc(sizeof(Global_element));
    new_global_el->name = strdup(name);
    new_global_el->type = strdup(type);
    new_global_el->params = params;

    if(global == NULL)
    {
        global = new_global_el;
        return new_global_el;
    }

    for(aux = global; aux; aux = aux->next)
    {
        if(strcmp(aux->name, name) == 0) return NULL;
    }
    aux->next = new_global_el;

    return new_global_el;
}

void print_params(Params * params) {
    Params * aux;
    int i;

    if (params == NULL) return;

    printf("(");
    for (aux = params, i = 0; params->next; aux = aux->next, i++)
    {   
        if(i == 0)
            printf("%s",aux->type);
        else
            printf(",%s",aux->type);
    }
    printf(")\t");

}

void show_Global_table()
{
    Global_element * aux = global;
    printf("===== Global Symbol Table =====\n");

    while(aux) {
        printf("%s\t",aux->name);
        print_params(aux->params);
        printf("%s\n", aux->type);
        aux = aux->next;
    }

    

}


void show_Functions_table()
{
    Function * aux = funcs;

    while(aux) 
    {
        print_Function_table(aux);
        aux = aux->down;
    }

}

void print_Function_table(Function * func) {

    Function_element * aux = func->next;

    // ex function name -> factorial ( int )
    // func name já terá de vir formatado correctamente

    printf("===== Function %s Symbol Table =====\n",func->name);
    while(aux)
    {
        printf("%s\t%s\t", aux->name, aux->type);
        if(aux->param != NULL)
            printf("param\n");
        else
        {
            printf("\n");
        }

        aux = aux->next;
    }

}

/*
void clean_table()
{
    // TODO
}
*/
