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
    printf("id:%s type:%s extra:%s\n", node->id, node->str, node->extra);
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

   // print_node(u);

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

void print_func_params(n * head, int dots) {
    print_dots(dots + 2); printf("ParamDecl\n");
    
    while(head) {

        print_dots(dots+2+2);printf("%s\n", head->str);
        print_dots(dots+2+2);printf("Id(%s)\n", head->id);
        
        head = head->right;
    }
}

void print_func_header(n * head, int dots) {

    print_dots(dots); printf("FuncHeader\n");
    print_dots(dots + 2); printf("Id(%s)\n", head->id);
    if(head->extra != NULL) {print_dots(dots + 2); printf("%s\n", head->extra);}
    print_dots(dots + 2); printf("FuncParams\n");

    print_func_params(head->down->down, dots + 2);

}

void print_dec(n* head, int dots) {
    
    if(strcmp("VarDecl", head->str) == 0) {
       
        print_dots(dots);    printf("VarDecl\n");
        print_dots(dots + 2);printf("%s\n", head->down->str);
        print_dots(dots + 2);printf("Id(%s)\n", head->down->id);
        
    }
    else if (strcmp("FuncDecl", head->str) == 0) {
        
        print_dots(dots);printf("FuncDecl\n");
        print_func_header(head->down, dots + 2);
        print_func_body(head->down->right, dots + 2);
    }

}

void print_func_body(n * head, int dots) {
    dots += 2;
    print_dots(dots); printf("FuncBody\n");
    n * aux = head->down;

    
    while(aux) {
            print_dec(aux, dots + 2);
            aux = aux->right;
        
    }

}


void print_declarations(n * head, int dots) {

    while(head) {
        print_dec(head, dots);
        head = head->right;
    }


}


void print_tree(n * head, int dots) {
    
    printf("Program\n");
    print_declarations(head->down, dots + 2);
    
}   
