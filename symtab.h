#ifndef SYMTAB_H
#define SYMTAB_H


typedef struct _t3 {
    char *type;
    struct _t3 *next;
} Params;

typedef struct _t0 {
    char *name;
    char *params;
    char *type;
    struct _t0 *next;
} Global_element;






typedef struct _t1{
	char *name;
    char *type;
    char *param;
	struct _t1 *next;
} Function_element;

typedef struct _t2 {
    char *name;
    Function_element *next;
    struct _t2 *down;
} Function;

/*
Function_element *insert_el(char *str);
void show_table();
void clean_table();
Function_element *search_el(char *str);*/



Function * insert_Function(char *name);
Function_element * insert_Func_element(char * name, char * type, char * param, Function * func);
Global_element * insert_Global_element(char * name, char * type, char * params);


void show_Global_table();
void show_Functions_table();
void print_Function_table(Function * func);


#endif