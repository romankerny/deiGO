#include "structures.h"
#include "functions.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>



n * set_type (n * head, char * _str) {
    n * tmp = head;
    while(tmp) {
        tmp->down->str = _str;
        tmp = tmp->right;
    }
    return head;
}

void print_node(n * node) {
    printf("type:%s", node->str);
}

n * add_to_end_of_list (n * head, n * to_add) {

    n * first = head;

    if(head == NULL) return to_add;

    while(head->right) {
        head = head->right;
    }
    head->right = to_add;

    return first;
}

n * add_node(char * _str, n * _down, n * _right) {

    n * node = malloc(sizeof(n));
    node->str = _str;
    node->down = _down;
    node->right = _right;
    return node;

}


n * add_node_to_list(n * head, char * str, n * down, n * right) {
    
    n * u = add_node(str, down, right);
    n * tmp;

   // print_node(u);
    
    if(head==NULL) {return u;}

    for(tmp = head; tmp->right; tmp = tmp->right) ;
    tmp->right = u;

    return head;

}


n * add_node_to_list_beggining(n * head, char * str, n * down, n * right) {
    

    n * u = add_node(str, down, right);
    n * tmp;
    


    if(head==NULL) {return u;}

    tmp = head;
    
    while(tmp->right) {
            tmp = tmp->right;
    }

    u->right = head;
    return u;

}



void print_dots(int n) {
    int i;
    for (i = 0; i < n; i++) printf(".");
}


void print_node_from_tree(n * head, int dots) {
    if(head->str != NULL) {
        print_dots(dots);
        printf("%s\n", head->str);
    }
}


void print_tree(n * head, int dots) {
    
    while(head) {
        
        print_node_from_tree(head, dots);
        print_tree(head->down, dots + 2);
        head = head->right;
    }
    
}   
