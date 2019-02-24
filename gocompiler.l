%{
    int flag = 0;
%}
reserved break|case|chan|const|continue|default|defer|fallthrough|go|goto|import|interface|map|range|select|struct|switch|type|"++"|"--"|"&"|"|"|"<<"|">>"|"&^"|"+="|"-="|"*="|"/="|"%="|"&="|"|="|"^="|"<<="|">>="|"&^="|"<-"|":="|"..."

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

chars_for_STRLIT  [^\n\r\"]

escape_sequence  \(n|t|r|f|"|\)

STRLIT \"({chars_for_STRLIT}|escape_sequence)*\"


%X              COMMENT1 COMMENT2

%%
{reserved} {if(flag){printf("RESERVED\n");}}
";" {if(flag){printf("SEMICOLON\n");}}
"_" {if(flag){printf("BLANKID\n");}}
"package" {if(flag){printf("PACKAGE\n");}}
"return" {if(flag){printf("RETURN\n");}}
"&&" {if(flag){printf("AND\n");}}
"=" {if(flag){printf("ASSIGN\n");}}
"*" {if(flag){printf("STAR\n");}}
"," {if(flag){printf("COMMA\n");}}
"/" {if(flag){printf("DIV\n");}}
"==" {if(flag){printf("EQ\n");}}
">=" {if(flag){printf("GE\n");}}
">" {if(flag){printf("GT\n");}}
"{" {if(flag){printf("LBRACE\n");}}
"<=" {if(flag){printf("LE\n");}}
"(" {if(flag){printf("LPAR\n");}}
"[" {if(flag){printf("LSQ\n");}}
"<" {if(flag){printf("LT\n");}}
"-" {if(flag){printf("MINUS\n");}}
"%" {if(flag){printf("MOD\n");}}
"!=" {if(flag){printf("NE\n");}}
"!" {if(flag){printf("NOT\n");}}
"||" {if(flag){printf("OR\n");}}
"+" {if(flag){printf("PLUS\n");}}
"}" {if(flag){printf("RBRACE\n");}}
")" {if(flag){printf("RPAR\n");}}
"]" {if(flag){printf("RSQ\n");}}
"else" {if(flag){printf("ELSE\n");}}
"for" {if(flag){printf("FOR\n");}}
"if" {if(flag){printf("IF\n");}}
"var" {if(flag){printf("VAR\n");}}
"int" {if(flag){printf("INT\n");}}
"float32" {if(flag){printf("FLOAT32\n");}}
"bool" {if(flag){printf("BOOL\n");}}
"string" {if(flag){printf("STRING\n");}}
"fmt.Println" {if(flag){printf("PRINT\n");}}
"strconv.Atoi" {if(flag){printf("PARSEINT\n");}}
"func" {if(flag){printf("FUNC\n");}}
"os.Args" {if(flag){printf("CMDARGS\n");}}


"/*" {BEGIN COMMENT1;}
"//" {BEGIN COMMENT2;}
<COMMENT1>"*/" {BEGIN 0;}
<COMMENT1>\n ;

<COMMENT2>"\n" {BEGIN 0;}
<COMMENT1>.  ;
<COMMENT2>.  ;


{STRLIT}   {if(flag) {printf("STRLIT(%s)\n", yytext);}}
{INTLIT}   {if(flag){printf("INTLIT(%s)\n", yytext);}}
{REALLIT}  {if(flag){printf("REALLIT(%s)\n", yytext);}}
{ID}       {if(flag){printf("ID(%s)\n", yytext);}}
\n	        ;
.           ;

%%
int main(int argc, char *argv[])
{
    if (argc == 2) {
        if (strcmp(argv[1], "-l") == 0)
            flag = 1;
        else
            flag = 0;
    }
    yylex();
    return 0;
}

int yywrap()
{
    return 1;
}
