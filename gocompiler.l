%{
 
%}
reserved break|case|chan|const|continue|default|defer|fallthrough|go|goto|import|interface|map|range|select|struct|switch|type|"++"|"--"

letter         [a-z]|[A-Z]|"_"

decimal_digit  [0-9]
octal_digit    [0-7]
hex_digit      [0-9]|[a-f]|[A-F]

ID             {letter}({letter}|{decimal_digit})*

decimal_lit    [1-9]{decimal_digit}*
octal_lit      0{octal_digit}+
hex_lit        0("x"|"X"){hex_digit}{hex_digit}*
INTLIT         {decimal_lit}|{octal_lit}|{hex_lit}|0

decimals       {decimal_digit}+
exponent       ("e"|"E")("+"|"-")?{decimals}
REALLIT        ({decimals}"."{decimals}?{exponent}?)|({decimals}{exponent})|("."{decimals}{exponent}?)

%%
{reserved} {printf("RESERVED\n");}
";" {printf("SEMICOLON\n");}
"_" {printf("BLANKID\n");}
"package" {printf("PACKAGE\n");}
"return" {printf("RETURN\n");}
"&&" {printf("AND\n");}
"=" {printf("ASSIGN\n");}
"*" {printf("STAR\n");}
"," {printf("COMMA\n");}
"/" {printf("DIV\n");}
"==" {printf("EQ\n");}
">=" {printf("GE\n");}
">" {printf("GT\n");}
"{" {printf("LBRACE\n");}
"<=" {printf("LE\n");}
"(" {printf("LPAR\n");}
"[" {printf("LSQ\n");}
"<" {printf("LT\n");}
"-" {printf("MINUS\n");}
"%" {printf("MOD\n");}
"!=" {printf("NE\n");}
"!" {printf("NOT\n");}
"||" {printf("OR\n");}
"+" {printf("PLUS\n");}
"}" {printf("RBRACE\n");}
")" {printf("RPAR\n");}
"]" {printf("RSQ\n");}
"else" {printf("ELSE\n");}
"for" {printf("FOR\n");}
"if" {printf("IF\n");}
"var" {printf("VAR\n");}
"int" {printf("INT\n");}
"float32" {printf("FLOAT32\n");}
"bool" {printf("BOOL\n");}
"string" {printf("STRING\n");}
"fmt.Println" {printf("PRINT\n");}
"strconv.Atoi" {printf("PARSEINT\n");}
"func" {printf("FUNC\n");}
"os.Args" {printf("CMDARGS\n");}

{INTLIT} {printf("INTLIT(%s)\n", yytext);}
{REALLIT} {printf("REALLIT(%s)\n", yytext);}
{ID} {printf("ID(%s)\n", yytext);}
\n	        ;
" "         ;

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
