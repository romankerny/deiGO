#include "structures.h"


n * add_node(char * str, char * id, n * down, n * right, char * extra);
n * grow_right(n * left, n * right);
n * add_node_to_list    (n * head, char * str, char * id, n * down, n * right, char * extra);
n * add_node_to_list_beggining(n * head, char * str, char * id, n * down, n * right, char * extra);
n * correct_type(n * head, char * str);
n * set_type (n * head, char * _str);
void print_tree(n * head, int dots);
void print_node(n * node);