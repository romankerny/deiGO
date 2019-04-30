%{
    #include <stdlib.h>
    #include <stdio.h>
    #include <string.h>
    #include "functions.h"
    #include "symtab.h"
    #include "semantics.h"
    #include "y.tab.h"    


    int flag = 0;
    int error = 0;

    int yylex(void);
    int yywrap(void);
    void yyerror (const char *s);

    n * tree_node_pointer = NULL;
    n * aux = NULL;

    Global_element *global = NULL;
    Function       *funcs  = NULL;

%}


%type<tree_node_pointer>Program
%type<tree_node_pointer>Declarations
%type<tree_node_pointer>VarDeclaration
%type<tree_node_pointer>VarSpec
%type<tree_node_pointer>ListComID
%type<tree_node_pointer>FuncBody
%type<tree_node_pointer>FuncDeclaration
%type<tree_node_pointer>Parameters
%type<tree_node_pointer>ListComIdType
%type<tree_node_pointer>VarsAndStatements
%type<tree_node_pointer>Expr
%type<tree_node_pointer>Statement
%type<tree_node_pointer>FuncInvocation
%type<tree_node_pointer>ListStatSemi
%type<tree_node_pointer>ListCommaExpr
%type<tree_node_pointer>ParseArgs


%type<s>Type



%union{
        char* s;
        location l;
        n * tree_node_pointer;
}


%right ASSIGN
%left OR
%left AND
%left EQ NE LT LE GT GE 
%left PLUS MINUS
%left STAR DIV MOD
%right NOT
%left LPAR


%token SEMICOLON BLANKID PACKAGE RETURN LBRACE LPAR LSQ RBRACE RPAR RSQ ELSE FOR IF VAR INT FLOAT32 BOOL STRING PRINT PARSEINT FUNC RESERVED
%token <l> AND ASSIGN STAR COMMA DIV EQ GE GT LE LT MINUS MOD NE NOT OR PLUS CMDARGS
%token <l> INTLIT
%token <l> REALLIT
%token <l> ID
%token <s> STRLIT


%%

Program: PACKAGE ID SEMICOLON Declarations
                                                    {$$ = tree_node_pointer = add_node("Program", $4, NULL);}
    ;

Declarations:                                       {$$ = NULL;}
    |     Declarations VarDeclaration SEMICOLON     {$$ = add_to_end_of_list ($1, $2);}
    |     Declarations FuncDeclaration SEMICOLON    {$$ = add_to_end_of_list ($1, $2);}
    ;

VarDeclaration: VAR VarSpec                          {$$ = $2;}
    |           VAR LPAR VarSpec SEMICOLON RPAR      {$$ = $3;}
    ;

VarSpec: ID ListComID Type                              {
                                                        char *aux = malloc(sizeof(char)*(strlen($1.str)+20));
                                                        sprintf(aux,"Id(%s)", $1.str);
                                                        n * id        = create_node(strdup(aux), NULL, NULL, $1.line, $1.col);
                                                        n * type_spec = add_node($3, NULL, id);
                                                        $$ = set_type($2, $3);
                                                        $$ = add_node_to_list_beggining($2, "VarDecl", type_spec, NULL);
                                                        }
    ;

ListComID:                                              {$$ = NULL;}
    |     ListComID COMMA ID                            {
        
                                                        char *aux = malloc(sizeof(char)*(strlen($3.str)+20));
                                                        sprintf(aux,"Id(%s)", $3.str);
                                                        n * id        = create_node(strdup(aux), NULL, NULL, $3.line, $3.col);
                                                        n * type_spec = add_node(NULL, NULL, id);
                                                        $$ = add_node_to_list($$, "VarDecl", type_spec, NULL);
                                                        }
    ;

Type: INT                                            {$$ = "Int";}                                                                   
    | FLOAT32                                        {$$ = "Float32";}
    | BOOL                                           {$$ = "Bool";} 
    | STRING                                         {$$ = "String";} 
    ;

FuncDeclaration: FUNC ID LPAR Parameters RPAR Type FuncBody       { 
                                                                    char *aux = malloc(sizeof(char)*(strlen($2.str)+20));
                                                                    sprintf(aux,"Id(%s)", $2.str);
                                                                    n * func_params = add_node("FuncParams", $4, NULL);
                                                                    n * type_spec   = add_node($6, NULL, func_params);
                                                                    n * id          = create_node(strdup(aux), NULL, type_spec, $2.line, $2.col);
                                                                    n * header      = add_node("FuncHeader", id, $7);
                                                                    $$ = add_node("FuncDecl", header, NULL);}

    |            FUNC ID LPAR Parameters RPAR      FuncBody       { 
                                                                    char *aux = malloc(sizeof(char)*(strlen($2.str)+20));
                                                                    sprintf(aux,"Id(%s)", $2.str);
                                                                    n * func_params = add_node("FuncParams", $4, NULL);
                                                                    n * id          = create_node(strdup(aux), NULL, func_params, $2.line, $2.col);
                                                                    n * header      = add_node("FuncHeader", id, $6);
                                                                    $$ = add_node("FuncDecl", header, NULL);}
    ;

Parameters:                                                        {$$ = NULL;}
    |     ID Type ListComIdType                                    {
                                                                    char *aux = malloc(sizeof(char)*(strlen($1.str)+20));
                                                                    sprintf(aux,"Id(%s)", $1.str);
                                                                    n * id         = create_node(strdup(aux), NULL, NULL, $1.line, $1.col);
                                                                    n * type_spec  = add_node($2, NULL, id);
                                                                    $$ = add_node_to_list_beggining($3, "ParamDecl", type_spec, NULL);
                                                                   }    
    ;

ListComIdType:                                                     {$$ = NULL;}
    |     ListComIdType COMMA ID Type                              {
                                                                    char *aux = malloc(sizeof(char)*(strlen($3.str)+20));
                                                                    sprintf(aux,"Id(%s)", $3.str);
                                                                    n * id        = create_node(strdup(aux), NULL, NULL, $3.line, $3.col);
                                                                    n * type_spec = add_node($4, NULL, id);
                                                                    $$ = add_node_to_list($$, "ParamDecl", type_spec, NULL);
                                                                    }
    ;

FuncBody: LBRACE VarsAndStatements RBRACE                         {$$ =  add_node("FuncBody", $2, NULL);}
    ;

VarsAndStatements:                                                {$$ = NULL;}
    |     VarsAndStatements SEMICOLON                             {$$ = $1;}
    |     VarsAndStatements VarDeclaration SEMICOLON              {$$ = add_to_end_of_list ($1, $2);}   
    |     VarsAndStatements Statement SEMICOLON                   {$$ = add_to_end_of_list ($1, $2);}
    ;

Statement: ID ASSIGN Expr {char *aux = malloc(sizeof(char)*(strlen($1.str)+20));
                        sprintf(aux, "Id(%s)", $1.str);
                        $$ = create_node("Assign", create_node(strdup(aux), NULL, $3, $1.line, $1.col), NULL, $2.line, $2.col);}
    |     LBRACE ListStatSemi RBRACE                                                 {if(need_to_create_block($2)) {
                                                                                        $$ = add_node("Block", $2, NULL);
                                                                                     } else {
                                                                                        $$ = add_to_end_of_list($2, NULL);
                                                                                     }   
                                                                                    }

    |     IF Expr LBRACE ListStatSemi RBRACE                                         {
                                                                                      n * block2       = add_node("Block", NULL, NULL);
                                                                                      $2->right = add_node("Block", $4, block2);
                                                                                      $$ = add_node("If", $2, NULL);
                                                                                     }
    |     IF Expr LBRACE ListStatSemi RBRACE ELSE LBRACE ListStatSemi RBRACE         {
                                                                                     n * block2       = add_node("Block", $8, NULL);
                                                                                     $2->right        = add_node("Block", $4, block2);
                                                                                     $$ = add_node("If", $2, NULL);
                                                                                     }
    |     FOR      LBRACE ListStatSemi RBRACE                                        { n* block = add_node("Block", $3, NULL);
                                                                                       $$ = add_node("For", block, NULL); }

    |     FOR Expr LBRACE ListStatSemi RBRACE                                        {$2->right = add_node("Block", $4, NULL);
                                                                                        $$ = add_node("For", $2, NULL);}

    |     RETURN                                                                     {$$ = add_node("Return", NULL, NULL);}
    |     RETURN Expr                                                                {$$ = add_node("Return", $2, NULL);;}
    |     FuncInvocation                                                             {$$ = add_node("Call", $1, NULL);}
    |     ParseArgs                                                                  {$$ = $1;}
    |     PRINT LPAR Expr   RPAR                                                     {$$ = add_node("Print", $3, NULL);}
    |     PRINT LPAR STRLIT RPAR                                                     {char *aux = malloc(sizeof(char)*(strlen($3)+20));
                                                                                      sprintf(aux,"StrLit(%s)", $3);
                                                                                      n * strlit = add_node(strdup(aux), NULL, NULL);
                                                                                      $$ = add_node("Print", strlit, NULL);
                                                                                     }
    |     error                                                                      {$$ = add_node(NULL, NULL, NULL); error = 1;}
    ;

ListStatSemi:                                                                        {$$ = NULL;}
    |     ListStatSemi Statement SEMICOLON                                           {$$ = add_to_end_of_list($1,$2);}
    ;

ParseArgs: ID COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR           {  char *aux = malloc(sizeof(char)*(strlen($1.str)+20));
                                                                                        sprintf(aux,"Id(%s)", $1.str);
                                                                                        n * left      = create_node(strdup(aux), NULL, $9, $1.line, $1.col);
                                                                                        $$            = create_node("ParseArgs", left, NULL, $7.line, $7.col);
                                                                                     }
    |      ID COMMA BLANKID ASSIGN PARSEINT LPAR error RPAR                          {$$ = add_node(NULL, NULL, NULL); error = 1;}
    ;

FuncInvocation: ID LPAR RPAR {char *aux = malloc(sizeof(char)*(strlen($1.str)+20));
                                sprintf(aux, "Id(%s)", $1.str);
                                $$ = create_node(strdup(aux), NULL, NULL, $1.line, $1.col); }

    | ID LPAR Expr ListCommaExpr RPAR { char *aux = malloc(sizeof(char)*(strlen($1.str)+20));
                                        sprintf(aux, "Id(%s)", $1.str);
                                        $$ = add_to_end_of_list (create_node(strdup(aux), NULL, $3, $1.line, $1.col), $4);}
    | ID LPAR error RPAR {$$ = add_node(NULL, NULL, NULL); error = 1;}
    ;

ListCommaExpr:                 {$$ = NULL;}
    | ListCommaExpr COMMA Expr {$$ = add_to_end_of_list($1, $3);}
    ;

Expr:   Expr AND Expr    {$$ =  create_node("And", $1, NULL, $2.line, $2.col); $1->right = $3;}
    |   Expr OR Expr     {$$ =  create_node("Or", $1, NULL, $2.line, $2.col); $1->right = $3;}
    |   Expr LT Expr     {$$ =  create_node("Lt", $1, NULL, $2.line, $2.col); $1->right = $3;}
    |   Expr GT Expr     {$$ =  create_node("Gt", $1, NULL, $2.line, $2.col); $1->right = $3;}
    |   Expr EQ Expr     {$$ =  create_node("Eq", $1, NULL, $2.line, $2.col); $1->right = $3;}
    |   Expr NE Expr     {$$ =  create_node("Ne", $1, NULL, $2.line, $2.col); $1->right = $3;}
    |   Expr LE Expr     {$$ =  create_node("Le", $1, NULL, $2.line, $2.col); $1->right = $3;}
    |   Expr GE Expr     {$$ =  create_node("Ge", $1, NULL, $2.line, $2.col); $1->right = $3;}
    |   Expr PLUS Expr   {$$ =  create_node("Add", $1, NULL, $2.line, $2.col); $1->right = $3;}
    |   Expr MINUS Expr  {$$ =  create_node("Sub", $1, NULL, $2.line, $2.col); $1->right = $3;}
    |   Expr STAR Expr   {$$ =  create_node("Mul", $1, NULL, $2.line, $2.col); $1->right = $3;}
    |   Expr DIV Expr    {$$ =  create_node("Div", $1, NULL, $2.line, $2.col); $1->right = $3;}
    |   Expr MOD Expr    {$$ =  create_node("Mod", $1, NULL, $2.line, $2.col); $1->right = $3;}
    |   NOT Expr         {$$ =  create_node("Not", $2, NULL, $1.line, $1.col);}
    |   MINUS Expr %prec NOT       {$$ = create_node("Minus", $2, NULL, $1.line, $1.col);}
    |   PLUS Expr  %prec NOT      {$$ = create_node("Plus", $2, NULL, $1.line, $1.col);}
    |   INTLIT           {char *aux = malloc(sizeof(char)*(strlen($1.str)+20));
                         sprintf(aux, "IntLit(%s)", $1.str);
                         $$ = create_node(strdup(aux), NULL, NULL, $1.line, $1.col); }

    |   REALLIT          {char *aux = malloc(sizeof(char)*(strlen($1.str)+20));
                         sprintf(aux, "RealLit(%s)", $1.str);
                         $$ = create_node(strdup(aux), NULL, NULL, $1.line, $1.col); }

    |   ID               {char *aux = malloc(sizeof(char)*(strlen($1.str)+20));
                         sprintf(aux, "Id(%s)", $1.str);
                         $$ = create_node(strdup(aux), NULL, NULL, $1.line, $1.col); }   
    |   FuncInvocation  {$$ = add_node("Call", $1, NULL);}
    |   LPAR Expr RPAR  {$$ = $2;}
    |   LPAR error RPAR {$$ = add_node(NULL, NULL, NULL); error = 1;}
    ;




%%

int main(int argc, char *argv[])
{

    int print_tr = 0;
    int flag_s = 0;

    if (argc == 2) {
        if (strcmp(argv[1], "-l") == 0) {
            flag = 1;
        }
        if (strcmp(argv[1], "-t") == 0) {
             print_tr = 1;
        }
        if (strcmp(argv[1], "-s") == 0) {
             flag_s = 1;
        }
    }
    if(flag)
        yylex();
     else
        yyparse();

    if (error == 0) {
        if (print_tr) {
            print_tree(tree_node_pointer, 0);
        } else {
            check_program(tree_node_pointer);
            if(flag_s) {
                show_Global_table();
                show_Functions_table();
                print_tree(tree_node_pointer, 0);
            }
        }

    }
    return 0;
}



