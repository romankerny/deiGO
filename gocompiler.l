%{
 
%}
reserved break|case|chan|const|continue|default|defer|fallthrough|go|goto|import|interface|map|range|select|struct|switch|type|"++"|"--"

%%
{reserved} {printf("RESERVED");}
";" {printf("SEMICOLON");}
"_" {printf("BLANKID");}
"package" {printf("PACKAGE");}
"return" {printf("RETURN");}
"&&" {printf("AND");}
"=" {printf("ASSIGN");}
"*" {printf("STAR");}
"," {printf("COMMA");}
"/" {printf("DIV");}
"==" {printf("EQ");}
">=" {printf("GE");}
">" {printf("GT");}
"{" {printf("LBRACE");}
"<=" {printf("LE");}
"(" {printf("LPAR");}
"[" {printf("LSQ");}
"<" {printf("LT");}
"-" {printf("MINUS");}
"%" {printf("MOD");}
"!=" {printf("NE");}
"!" {printf("NOT");}
"||" {printf("OR");}
"+" {printf("PLUS");}
"}" {printf("RBRACE");}
")" {printf("RPAR");}
"]" {printf("RSQ");}
"else" {printf("ELSE");}
"for" {printf("FOR");}
"if" {printf("IF");}
"var" {printf("VAR");}
"int" {printf("INT");}
"float32" {printf("FLOAT32");}
"bool" {printf("BOOL");}
"string" {printf("STRING");}
"fmt.Println" {printf("PRINT");}
"strconv.Atoi" {printf("PARSEINT");}
"func" {printf("FUNC");}
"os.Args" {printf("CMDARGS");}

%%
int main()
{   
    yylex();
    return 0;
}

int yywrap()
{
    return 1;
}
