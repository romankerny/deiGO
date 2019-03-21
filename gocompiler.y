%{
    #include <stdlib.h>
    #include <stdio.h>
    #include <string.h>

    int flag = 0;

    int yylex(void);
    void yyerror (const char *s);
%}

%union{
        int i;
        float f;
        char* s;
}

%left OR
%left AND
%left LT GT LE GE
%left EQ NE
%left PLUS MINUS
%left STAR DIV MOD
%right NOT
%nonassoc LPAR

%token SEMICOLON BLANKID PACKAGE RETURN AND ASSIGN STAR COMMA DIV EQ GE GT LBRACE LE LPAR LSQ LT MINUS MOD NE NOT OR PLUS RBRACE RPAR RSQ ELSE FOR IF VAR INT FLOAT32 BOOL STRING PRINT PARSEINT FUNC CMDARGS
%token <i> INTLIT
%token <f> REALLIT
%token <s> ID
%token <s> STRLIT

%type <i> Expr


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
    |     ID Type ListComID Type
    ;

FuncBody: LBRACE VarsAndStatements RBRACE
    |     LBRACE RBRACE
    ;

VarsAndStatements: VarsAndStatements SEMICOLON
    |     VarsAndStatements VarDeclaration SEMICOLON
    |     VarsAndStatements Statement SEMICOLON
    ;

Statement: ID ASSIGN Expr
    |     LBRACE ListStatSemi RBRACE
    |     IF Expr LBRACE ListStatSemi RBRACE
    |     IF Expr LBRACE ListStatSemi RBRACE ELSE LBRACE ListStatSemi RBRACE
    |     FOR LBRACE ListStatSemi RBRACE
    |     FOR Expr LBRACE RBRACE ListStatSemi RBRACE
    |     RETURN
    |     RETURN Expr
    //|     FuncInvocation
    |     ParseArgs
    |     PRINT LPAR Expr RPAR
    |     PRINT LPAR STRLIT RPAR
    ;

ListStatSemi:
    |     ListStatSemi Statement SEMICOLON
    ;

ParseArgs: ID COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR
    ;

Expr:   Expr AND Expr   {$$ = ($1 && $3);}
    |   Expr OR Expr    {$$ = ($1 || $3);}
    |   Expr LT Expr    {$$ = ($1 < $3);}
    |   Expr GT Expr    {$$ = ($1 > $3);}
    |   Expr EQ Expr    {$$ = ($1 == $3);}
    |   Expr NE Expr    {$$ = ($1 != $3);}
    |   Expr LE Expr    {$$ = ($1 <= $3);}
    |   Expr GE Expr    {$$ = ($1 >= $3);}
    |   Expr PLUS Expr  {$$ = $1 + $3; printf("+");}
    |   Expr MINUS Expr {$$ = $1 - $3;}
    |   Expr STAR Expr  {$$ = $1 * $3;}
    |   Expr DIV Expr   {$$ = $1 / $3;}
    |   Expr MOD Expr   {$$ = $1 % $3;}
    |   NOT Expr        {$$ = !$2;}
    |   MINUS Expr      {$$ = -$2;}
    |   PLUS Expr       {$$ = $2;}
    |   INTLIT          {$$ = $1;}
    |   REALLIT         {$$ = $1;}
    |   ID              {$$ = 69;}
    // |   FuncInvocation
    |   LPAR Expr RPAR {$$ = $2;}
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


