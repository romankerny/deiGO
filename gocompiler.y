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
                                                    {$$ = add_node("Program", NULL, $4, NULL, NULL); print_tree($$, 0);}
    ;

Declarations:                                       {$$ = NULL;}
    |     Declarations VarDeclaration SEMICOLON     {$$ = $2;}
    |     Declarations FuncDeclaration SEMICOLON    {$$ = add_node_to_list($$, "FuncDecl", NULL, $2, NULL, NULL);}
    ;

VarDeclaration: VAR VarSpec                          {$$ = $2; }
    |           VAR LPAR VarSpec SEMICOLON RPAR      {$$ = $3;}
    ;

VarSpec: ID ListComID Type                             {$$ = set_type($2, $3); 
                                                        n * id = add_node($3, $1, NULL, NULL, NULL);
                                                        $$ = add_node_to_list_beggining($2, "VarDecl", NULL, id, NULL, NULL);}
    ;

ListComID:                                             {$$ = NULL;}
    |     ListComID COMMA ID                           {n * id = add_node(NULL, $3, NULL, NULL, NULL);
                                                        $$ = add_node_to_list($1, "VarDecl", NULL, id, NULL, NULL);}
    ;

Type: INT                                            {$$ = "Int";}                                                                          
    | FLOAT32                                        {$$ = "Float32";}   
    | BOOL                                           {$$ = "Bool";}   
    | STRING                                         {$$ = "String";}   
    ;
// n * add_node(char * str, char * id, n * down, n * right, char * extra);
FuncDeclaration: FUNC ID LPAR Parameters RPAR Type FuncBody       {
                                                                   n * paramDeclaration = add_node("ParamDecl", NULL, $4, NULL, NULL);
                                                                   n * funcParams =  add_node("FuncParams", $2, paramDeclaration, NULL, $6);
                                                                   $$ = add_node_to_list(NULL, "FuncHeader", NULL, funcParams, NULL, NULL);
                                                                   $$ = add_node_to_list($$, "FuncBody", NULL, $7, NULL, NULL);
                                                                  }

    |            FUNC ID LPAR Parameters RPAR      FuncBody       {
                                                                   n * paramDeclaration = add_node("ParamDecl", NULL, $4, NULL, NULL);
                                                                   n * funcParams =  add_node("FuncParams", $2, paramDeclaration, NULL, NULL);
                                                                   $$ = add_node_to_list(NULL, "FuncHeader", NULL, funcParams, NULL, NULL);
                                                                   $$ = add_node_to_list($$, "FuncBody", NULL, $6, NULL, NULL);
                                                                  }
    ;

Parameters:                                                       {$$ = NULL;}
    |     ID Type ListComIdType                                   {$$ = add_node_to_list_beggining($3, $2, $1, NULL, NULL, NULL);}    
    ;

ListComIdType:                                                    {$$ = NULL;}
    |     ListComIdType COMMA ID Type                             {$$ = add_node_to_list($$, $4, $3, NULL, NULL, NULL);}
    ;

FuncBody: LBRACE VarsAndStatements RBRACE                         {$$ = NULL;}
    ;

VarsAndStatements:                                                {$$ = NULL;}
    |     VarsAndStatements SEMICOLON
    |     VarsAndStatements VarDeclaration SEMICOLON 
    |     VarsAndStatements Statement SEMICOLON 
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


