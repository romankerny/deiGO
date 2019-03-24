#ifndef STRUCTURES_H
#define STRUCTURES_H

typedef struct _n {

    char * str;
    char * id;
    char * extra;
    struct _n * down;
    struct _n * right;

} n;


#endif