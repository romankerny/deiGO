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
    int   used;      // declared and not used error
    char *param;
	struct _t1 *next;
} Function_element;

typedef struct _t2 {
    char *name;
    char *name_no_params;
    Function_element *next;
    struct _t2 *down;
    int visited;
    int invalid;
} Function;

Function * insert_Function(char *name);
Function_element * insert_Func_element(char * name, char * type, char * param, Function * func);
Global_element * insert_Global_element(char * name, char * type, char * params);
Function_element * search_Element(Function * func, char * name);
Global_element * search_Global(char * name, int is_func);


void show_Global_table();
void show_Functions_table();
void print_Function_table(Function * func);
Function *search_Function(char * name);
Function* search_Function_by_name(char * name);
Function* get_Function(char * name);


char * get_Func_Type(Function * f);
void set_as_Used(Function_element * f);

#endif