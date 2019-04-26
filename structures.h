#ifndef STRUCTURES_H
#define STRUCTURES_H

typedef struct _l {
    int line;
    int col;
    char* str;
} location;

typedef struct _n {
    
    int line, col;

    char * str;
    struct _n * down;
    struct _n * right;

} n;

#endif