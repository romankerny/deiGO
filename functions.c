#include "structures.h"
#include "functions.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>



n * set_type (n * head, char * _str) {
    n * tmp = head;
    while(tmp) {
        tmp->str = _str;
        tmp = tmp->right;
    }
    return head;
}

n * add_node(char * _str, char * _id, n * _down, n * _right, char * _extra) {

    n * node = malloc(sizeof(n));
    node->str = _str;
    node->id = _id;
    node->extra = _extra;  // p causa de func Header ter 3 params
    node->down = _down;
    node->right = _right;
    return node;

}


n * add_node_to_list(n * head, char * str, char * id, n * down, n * right, char * extra) {
    
    n * u = add_node(str, id, down, right, extra);
    n * tmp;

    // printf("a adicionar %s %s %s\n", id, str, extra);

    if(head==NULL) {return u;}

    for(tmp = head; tmp->right; tmp = tmp->right) ;
    tmp->right = u;


    return head;

}


n * add_node_to_list_beggining(n * head, char * str, char * id, n * down, n * right, char * extra) {
    

    n * u = add_node(str, id, down, right, extra);
    n * tmp;


    if(head==NULL) {return u;}

    tmp = head;
    
    while(tmp) {
        tmp = tmp->right;
    }

    u->right = head;
    return u;

}



void print_dots(int n) {
    int i;
    for (i = 0; i < n; i++) printf(".");
}

void print_tree(n * head, int dots) {
    n * aux;
  

    if(head->down == NULL && !(strcmp(head->str,"FuncBody") == 0)) {
            // FINAIS
            print_dots(dots);printf("%s\n", head->str);
            print_dots(dots);printf("Id(%s)\n", head->id);
                    
    } else {
        if(strcmp(head->str,"FuncParams") == 0) {
 
            print_dots(dots);printf("Id(%s)\n", head->id);
            if(head->extra != NULL) {print_dots(dots);printf("%s\n", head->extra);}
            print_dots(dots);printf("FuncParams\n");
        } else {
            print_dots(dots);printf("%s\n", head->str);
        }

    }
    

    aux = head;

    if(head->down != NULL)  
        print_tree(head->down, dots + 2);
    
    
    if (aux->right != NULL) {
        print_tree(aux->right, dots);
    }
        
    

}