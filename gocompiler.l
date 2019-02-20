%{
 
%}
reserved break|case|chan|const|continue|default|defer|fallthrough|go|goto|import|interface|map|range|select|struct|switch|type|"++"|"--"
new_line       "\n"
decimal_digit  [0-9]
octal_digit    [0-7]
hex_digit      [0-9] | [a-f] | [A-F]

INTLIT        {decimal_lit} | {octal_lit} | {hex_lit}
decimal_lit    [1-9]{decimal_digit}*
octal_lit      0{octal_digit}+
hex_lit        0("x"|"X"){hex_digit}{hex_digit}*

REALLIT        [{decimals}"."{decimals}?{exponent}?,{decimals}{exponent},"."{decimals}{exponent}?]
decimals       {decimal_digit}+
exponent       ("e"|"E")["+"|"-"]{decimals}

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


.	;
{new_line}	;

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
