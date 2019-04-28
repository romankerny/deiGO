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
    new_Function->name = strdup(name);
    new_Function->next = NULL;

    if(funcs == NULL) {
        funcs = new_Function;
        return new_Function;
    }

    for (aux = funcs; aux->down; aux = aux->down);
    aux->down = new_Function;

    

    return new_Function;
}

Function_element * search_Element(Function * func, char * name)
{
    Function_element * aux = func->next;

    while(aux)
    {
        if(strcmp(aux->name, name) == 0) return aux;
        aux = aux->next;
    }

    return NULL;
}

Global_element * search_Global(char * name)
{
    Global_element * aux = global;
    
    while(aux)
    {
        if(strcmp(aux->name, name) == 0) return aux;
        aux = aux->next;
    }
    return NULL;
}

Function * search_Function(char * name)
{
    Function * aux = funcs;

    while(aux)
    {
        if(strcmp(aux->name, name) == 0) return aux;
        aux = aux->down;
    }

    return NULL;
}


Function_element * insert_Func_element(char * name, char * type, char * param, Function * func) {

    Function_element * aux;
    Function_element * new_func_el = malloc(sizeof(Function_element));
    new_func_el->next  = NULL;
    new_func_el->name  = strdup(name);
    new_func_el->type  = strdup(type);
    new_func_el->param = NULL;

    if(param != NULL)
        new_func_el->param = strdup(param);

    if(func->next == NULL) {
        func->next = new_func_el;
        return new_func_el;
    }

    for (aux = func->next; aux->next; aux = aux->next)
    {
        if(strcmp(aux->name, name) == 0) return NULL;
    }
    
    aux->next = new_func_el;



    return new_func_el;
    
}

Global_element * insert_Global_element(char * name, char * type, char * params) {
    
    Global_element * aux;
    Global_element * new_global_el = malloc(sizeof(Global_element));
    new_global_el->name = strdup(name);
    new_global_el->type = strdup(type);
    new_global_el->params = NULL;

    if(params != NULL)
        new_global_el->params = strdup(params);

    if(global == NULL)
    {
        global = new_global_el;
        return new_global_el;
    }

    for(aux = global; aux->next; aux = aux->next)
    {
        if(strcmp(aux->name, name) == 0) return NULL;
    }
    aux->next = new_global_el;

    return new_global_el;
}



void show_Global_table()
{
    Global_element * aux = global;
    printf("===== Global Symbol Table =====\n");

    while(aux) {
        printf("%s\t", aux->name);
        if(aux->params != NULL)
            printf("%s\t", aux->params);
        else
            printf("\t");
        printf("%s\n", aux->type);
        aux = aux->next;
    }

    printf("\n");
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
        printf("%s\t\t%s", aux->name, aux->type);
        if(aux->param != NULL)
            printf("\tparam\n");
        else
        {
            printf("\n");
        }

        aux = aux->next;
    }
    printf("\n");

}

/*
void clean_table()
{
    // TODO
}
*/
