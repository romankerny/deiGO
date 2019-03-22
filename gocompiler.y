%{
    #include <stdlib.h>
    #include <stdio.h>
    #include <string.h>

    int flag = 0;
    int error = 0;

    int yylex(void);
    void yyerror (const char *s);
%}

%union{
        int   i;
        float f;
        char* s;
}

%left OR
%left AND
%left EQ NE LT LE GT GE 
%left PLUS MINUS
%left STAR DIV MOD
%right NOT
%nonassoc LPAR
%right ASSIGN

%token SEMICOLON BLANKID PACKAGE RETURN AND ASSIGN STAR COMMA DIV EQ GE GT LBRACE LE LPAR LSQ LT MINUS MOD NE NOT OR PLUS RBRACE RPAR RSQ ELSE FOR IF VAR INT FLOAT32 BOOL STRING PRINT PARSEINT FUNC CMDARGS RESERVED
%token <i> INTLIT
%token <f> REALLIT
%token <s> ID
%token <s> STRLIT


%%

Program: PACKAGE ID SEMICOLON Declarations
    ;

Declarations:
    |     Declarations VarDeclaration SEMICOLON 
    |     Declarations FuncDeclaration SEMICOLON
    ;

VarDeclaration: VAR VarSpec
    |          VAR LPAR VarSpec SEMICOLON RPAR
    ;

VarSpec: ID ListComID Type
    ;

ListComID:
    |     ListComID COMMA ID
    ;

Type: INT
    | FLOAT32
    | BOOL
    | STRING
    ;

FuncDeclaration: FUNC ID LPAR Parameters RPAR Type FuncBody
    |     FUNC ID LPAR Parameters RPAR FuncBody
    ;

Parameters:
    |     ID Type ListComIdType
    ;

ListComIdType:
    |     ListComIdType COMMA ID Type
    ;

FuncBody: LBRACE VarsAndStatements RBRACE
    ;

VarsAndStatements: 
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
    | ID COMMA BLANKID ASSIGN PARSEINT LPAR error RPAR
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


