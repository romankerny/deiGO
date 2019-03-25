%{
    #include <stdlib.h>
    #include <stdio.h>
    #include <string.h>
    #include "functions.h"
    #include "y.tab.h"    


    int flag = 0;
    int error = 0;

    int yylex(void);
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
%nonassoc LPAR


%token SEMICOLON BLANKID PACKAGE RETURN AND ASSIGN STAR COMMA DIV EQ GE GT LBRACE LE LPAR LSQ LT MINUS MOD NE NOT OR PLUS RBRACE RPAR RSQ ELSE FOR IF VAR INT FLOAT32 BOOL STRING PRINT PARSEINT FUNC CMDARGS RESERVED
%token <i> INTLIT
%token <f> REALLIT
%token <s> ID
%token <s> STRLIT


%%

Program: PACKAGE ID SEMICOLON Declarations
                                                    {$$ = tree_node_pointer = add_node("Program", $4, NULL);  print_tree(tree_node_pointer, 0);}
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
                                                                    n * type_spec   = add_node(NULL, NULL, func_params);
                                                                    n * id          = add_node(strdup(aux), NULL, type_spec);
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
    |     VarsAndStatements Statement SEMICOLON                   {printf("statemet\n");}
    ;

Statement: ID ASSIGN Expr
    |     LBRACE ListStatSemi RBRACE
    |     IF Expr LBRACE ListStatSemi RBRACE
    |     IF Expr LBRACE ListStatSemi RBRACE ELSE LBRACE ListStatSemi RBRACE
    |     FOR      LBRACE ListStatSemi RBRACE
    |     FOR Expr LBRACE ListStatSemi RBRACE
    |     RETURN
    |     RETURN Expr
    |     FuncInvocation 
    |     ParseArgs      
    |     PRINT LPAR Expr RPAR
    |     PRINT LPAR STRLIT RPAR
    |     error
    ;

ListStatSemi:
    |     ListStatSemi Statement SEMICOLON
    ;

ParseArgs: ID COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR
    |      ID COMMA BLANKID ASSIGN PARSEINT LPAR error RPAR
    ;

FuncInvocation: ID LPAR RPAR
    | ID LPAR Expr ListCommaExpr RPAR
    | ID LPAR error RPAR
    ;

ListCommaExpr:
    | ListCommaExpr COMMA Expr
    ;

Expr:   Expr AND Expr   
    |   Expr OR Expr   
    |   Expr LT Expr 
    |   Expr GT Expr   
    |   Expr EQ Expr  
    |   Expr NE Expr    
    |   Expr LE Expr    
    |   Expr GE Expr    
    |   Expr PLUS Expr   
    |   Expr MINUS Expr  
    |   Expr STAR Expr   
    |   Expr DIV Expr    
    |   Expr MOD Expr    
    |   NOT Expr        
    |   MINUS Expr      
    |   PLUS Expr       
    |   INTLIT          
    |   REALLIT         
    |   ID            
    |   FuncInvocation
    |   LPAR Expr RPAR
    |   LPAR error RPAR
    ;




%%

int main(int argc, char *argv[])
{
    if (argc == 2) {
        if (strcmp(argv[1], "-l") == 0)
            flag = 1;
    }
    yyparse();
    return 0;
}


