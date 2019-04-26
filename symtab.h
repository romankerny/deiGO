#ifndef SYMTAB_H
#define SYMTAB_H


typedef struct _t3 {
    char *type;
    struct _t3 *next;
} Params;

typedef struct _t0 {
    char *name;
    Params *params;
    char *type;
} Global_element;

typedef struct _t1{
	char *name;
    char *type;
    char *param;
	struct _t1 *next;
} Func_element;

typedef struct _t2 {
    char *name;
    Func_element *next;
    struct _t2 *down;
} Function;

Func_element *insert_el(char *str);
void show_table();
void clean_table();
Func_element *search_el(char *str);

#endif