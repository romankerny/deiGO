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
        if(strcmp(aux->name, name) == 0) {
            return aux;
        }
        aux = aux->next;
    }

    return NULL;
}

Global_element * search_Global(char * name, int is_func)
{
    Global_element * aux = global;

    
    while(aux)
    {
        if(strcmp(aux->name, name) == 0)  {

            if (aux->params == NULL)
                return aux;
            else if (is_func)
                return aux;
        }
        aux = aux->next;
    }
    return NULL;
}

Function* search_Function_by_name(char * name)
{
    Function * aux = funcs;
    while(aux)
    {
        char *clean_name = calloc(strlen(aux->name), sizeof(char));
        int i = 0;
        while (aux->name[i] != '(') {
            clean_name[i] = aux->name[i];
            i++;           
        }
        clean_name[i] = '\0';
        
        if(strcmp(clean_name, name) == 0) {
            free(clean_name);
            return aux;
        }
        aux = aux->down;
        free(clean_name);
    }
    return NULL;
}

int check_if_param_Already_Defined(Function * to_return, char * param_id)
{

    Function_element * aux = to_return->next;

    while(aux)
    {   
        if(strcmp(aux->name, param_id) == 0) 
        {
            return 1;
        }
        aux = aux->next;
    }

    return 0;
}

Function* search_Function(char * name)
{
    Function * aux = funcs;
    while(aux)
    {   
        if(strcmp(aux->name, name) == 0) {
            return aux;
        }
        aux = aux->down;
    }
    return NULL;
}

void set_as_Used(Function_element * f) {
    f->used = 1;
}

Function_element * insert_Func_element(char * name, char * type, char * param, Function * func) {

    Function_element * aux;
    Function_element * new_func_el = malloc(sizeof(Function_element));
    new_func_el->next  = NULL;
    new_func_el->name  = NULL;
    new_func_el->param = NULL;
    new_func_el->type  = NULL;
    new_func_el->used  = 0;

     if(name != NULL)
        new_func_el->name  = strdup(name);

    if(type != NULL)
        new_func_el->type  = strdup(type);

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
    new_global_el->next = NULL;

    if(params != NULL)
        new_global_el->params = strdup(params);

    if(global == NULL)
    {
        global = new_global_el;
        return new_global_el;
    }

   
    for(aux = global; aux; aux = aux->next)
    {
        if(strcmp(aux->name, name) == 0) return NULL;
        if(aux->next == NULL) break;
    }
    aux->next = new_global_el;

    return new_global_el;
}

/*
int check_if_global_element_exists(char * name) {

    Global_element * aux;
    while(aux)
    {
        if(strcmp(aux->name, name) == 0) return 0;
        aux = aux->next;
    }
    return 0;
}*/



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

char * get_Func_Type(Function * f) {

    char * return_type = NULL;
    if(f->next->type != NULL) {
        return_type = strdup(f->next->type);
    } 
    return return_type;
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
