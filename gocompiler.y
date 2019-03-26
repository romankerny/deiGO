%{
    #include <stdlib.h>
    #include <stdio.h>
    #include <string.h>
    #include "functions.h"
    #include "y.tab.h"    


    int flag = 0;
    int error = 0;

    int yylex(void);
    int yywrap(void);
    void yyerror (const char *s);


    n * tree_node_pointer = NULL;
    n * aux = NULL;
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
        int   i;
        float f;
        char* s;
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


%token SEMICOLON BLANKID PACKAGE RETURN AND ASSIGN STAR COMMA DIV EQ GE GT LBRACE LE LPAR LSQ LT MINUS MOD NE NOT OR PLUS RBRACE RPAR RSQ ELSE FOR IF VAR INT FLOAT32 BOOL STRING PRINT PARSEINT FUNC CMDARGS RESERVED
%token <i> INTLIT
%token <s> REALLIT
%token <s> ID
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
                                                        char aux [1024];
                                                        sprintf(aux,"Id(%s)", $1);
                                                        n * id        = add_node(strdup(aux), NULL, NULL);
                                                        n * type_spec = add_node($3, NULL, id);
                                                        $$ = set_type($2, $3);
                                                        $$ = add_node_to_list_beggining($2, "VarDecl", type_spec, NULL);
                                                        }
    ;

ListComID:                                              {$$ = NULL;}
    |     ListComID COMMA ID                            {
        
                                                        char aux [1024];
                                                        sprintf(aux,"Id(%s)", $3);
                                                        n * id        = add_node(strdup(aux), NULL, NULL);
                                                        n * type_spec = add_node(NULL, NULL, id);
                                                        $$ = add_node_to_list($$, "VarDecl", type_spec, NULL);
                                                        }
    ;

Type: INT                                            {$$ = "Int";}                                                                   
    | FLOAT32                                        {$$ = "Float32";}
    | BOOL                                           {$$ = "Bool";} 
    | STRING                                         {$$ = "String";} 
    ;

// n * add_node(char * str, char * id, n * down, n * right, char * extra);



FuncDeclaration: FUNC ID LPAR Parameters RPAR Type FuncBody       { 
                                                                    char aux [1024];
                                                                    sprintf(aux,"Id(%s)", $2);
                                                                    n * func_params = add_node("FuncParams", $4, NULL);
                                                                    n * type_spec   = add_node($6, NULL, func_params);
                                                                    n * id          = add_node(strdup(aux), NULL, type_spec);
                                                                    n * header      = add_node("FuncHeader", id, $7);
                                                                    $$ = add_node("FuncDecl", header, NULL);}

    |            FUNC ID LPAR Parameters RPAR      FuncBody       { 
                                                                    char aux [1024];
                                                                    sprintf(aux,"Id(%s)", $2);
                                                                    n * func_params = add_node("FuncParams", $4, NULL);
                                                                    n * id          = add_node(strdup(aux), NULL, func_params);
                                                                    n * header      = add_node("FuncHeader", id, $6);
                                                                    $$ = add_node("FuncDecl", header, NULL);}
    ;

Parameters:                                                        {$$ = NULL;}
    |     ID Type ListComIdType                                    {
                                                                    char aux [1024];
                                                                    sprintf(aux,"Id(%s)", $1);
                                                                    n * id         = add_node(strdup(aux), NULL, NULL);
                                                                    n * type_spec  = add_node($2, NULL, id);
                                                                    $$ = add_node_to_list_beggining($3, "ParamDecl", type_spec, NULL);
                                                                   }    
    ;

ListComIdType:                                                     {$$ = NULL;}
    |     ListComIdType COMMA ID Type                              {
                                                                    char aux [1024];
                                                                    sprintf(aux,"Id(%s)", $3);
                                                                    n * id        = add_node(strdup(aux), NULL, NULL);
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

Statement: ID ASSIGN Expr {char aux[1024];
                        sprintf(aux, "Id(%s)", $1);
                        $$ = add_node("Assign", add_node(strdup(aux), NULL, $3), NULL);}
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
    |     PRINT LPAR STRLIT RPAR                                                     {char aux [1024];
                                                                                      sprintf(aux,"StrLit(\"%s\")", $3);
                                                                                      n * strlit = add_node(strdup(aux), NULL, NULL);
                                                                                      $$ = add_node("Print", strlit, NULL);
                                                                                     }
    |     error                                                                      {$$ = add_node(NULL, NULL, NULL); error = 1;}
    ;

ListStatSemi:                                                                        {$$ = NULL;}
    |     ListStatSemi Statement SEMICOLON                                           {$$ = add_to_end_of_list($1,$2);}
    ;

ParseArgs: ID COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR           {  char aux [1024];
                                                                                        sprintf(aux,"Id(%s)", $1);
                                                                                        n * left      = add_node(strdup(aux), NULL, $9);
                                                                                        $$            = add_node("ParseArgs", left, NULL);
                                                                                     }
    |      ID COMMA BLANKID ASSIGN PARSEINT LPAR error RPAR                          {$$ = add_node(NULL, NULL, NULL); error = 1;}
    ;

FuncInvocation: ID LPAR RPAR {char aux[1024];
                                sprintf(aux, "Id(%s)", $1);
                                $$ = add_node(strdup(aux), NULL, NULL); }

    | ID LPAR Expr ListCommaExpr RPAR { char aux[1024];
                                        sprintf(aux, "Id(%s)", $1);
                                        $$ = add_to_end_of_list (add_node(strdup(aux), NULL, $3), $4);}
    | ID LPAR error RPAR {$$ = add_node(NULL, NULL, NULL); error = 1;}
    ;

ListCommaExpr:                 {$$ = NULL;}
    | ListCommaExpr COMMA Expr {$$ = add_to_end_of_list($1, $3);}
    ;

Expr:   Expr AND Expr    {$$ = add_node("And", $1, NULL); $1->right = $3;}
    |   Expr OR Expr     {$$ = add_node("Or", $1, NULL); $1->right = $3;}
    |   Expr LT Expr     {$$ = add_node("Lt", $1, NULL); $1->right = $3;}
    |   Expr GT Expr     {$$ = add_node("Gt", $1, NULL); $1->right = $3;}
    |   Expr EQ Expr     {$$ = add_node("Eq", $1, NULL); $1->right = $3;}
    |   Expr NE Expr     {$$ = add_node("Ne", $1, NULL); $1->right = $3;}
    |   Expr LE Expr     {$$ = add_node("Le", $1, NULL); $1->right = $3;}
    |   Expr GE Expr     {$$ = add_node("Ge", $1, NULL); $1->right = $3;}
    |   Expr PLUS Expr   {$$ = add_node("Add", $1, NULL); $1->right = $3;}
    |   Expr MINUS Expr  {$$ = add_node("Sub", $1, NULL); $1->right = $3;}
    |   Expr STAR Expr   {$$ = add_node("Mul", $1, NULL); $1->right = $3;}
    |   Expr DIV Expr    {$$ = add_node("Div", $1, NULL); $1->right = $3;}
    |   Expr MOD Expr    {$$ = add_node("Mod", $1, NULL); $1->right = $3;}
    |   NOT Expr         {$$ = add_node("Not", $2, NULL);}
    |   MINUS Expr %prec NOT       {$$ = add_node("Minus", $2, NULL);}
    |   PLUS Expr  %prec NOT      {$$ = add_node("Plus", $2, NULL);}
    |   INTLIT           {char aux[1024];
                         sprintf(aux, "IntLit(%d)", $1);
                         $$ = add_node(strdup(aux), NULL, NULL); }

    |   REALLIT          {char aux[1024];
                         sprintf(aux, "RealLit(%s)", $1);
                         $$ = add_node(strdup(aux), NULL, NULL); }

    |   ID               {char aux[1024];
                         sprintf(aux, "Id(%s)", $1);
                         $$ = add_node(strdup(aux), NULL, NULL); }   
    |   FuncInvocation  {$$ = add_node("Call", $1, NULL);}
    |   LPAR Expr RPAR  {$$ = $2;}
    |   LPAR error RPAR {$$ = add_node(NULL, NULL, NULL); error = 1;}
    ;




%%

int main(int argc, char *argv[])
{
    int print_tr = 0;

    if (argc == 2) {
        if (strcmp(argv[1], "-l") == 0) {
            flag = 1;
        }
        if (strcmp(argv[1], "-t") == 0) {
             print_tr = 1;
        }
    }

    if(flag == 1)
        yylex();
     else
        yyparse();

    if (error == 0 && print_tr == 1) {
        print_tree(tree_node_pointer, 0);
    }

    return 0;
}



