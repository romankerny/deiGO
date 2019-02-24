%{
    int flag = 0;
    int colno = 0;
    int comment_begining_line, comment_begining_column;
%}
reserved break|case|chan|const|continue|default|defer|fallthrough|go|goto|import|interface|map|range|select|struct|switch|type|"++"|"--"|"&"|"|"|"<<"|">>"|"&^"|"+="|"-="|"*="|"/="|"%="|"&="|"|="|"^="|"<<="|">>="|"&^="|"<-"|":="|"..."|":"|"."

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
";" {colno += yyleng; if(flag){printf("SEMICOLON\n");}}
"_" {colno += yyleng; if(flag){printf("BLANKID\n");}}
"package" {colno += yyleng; if(flag){printf("PACKAGE\n");}}
"return" {colno += yyleng; if(flag){printf("RETURN\n");}}
"&&" {colno += yyleng; if(flag){printf("AND\n");}}
"=" {colno += yyleng; if(flag){printf("ASSIGN\n");}}
"*" {colno += yyleng; if(flag){printf("STAR\n");}}
"," {colno += yyleng; if(flag){printf("COMMA\n");}}
"/" {colno += yyleng; if(flag){printf("DIV\n");}}
"==" {colno += yyleng; if(flag){printf("EQ\n");}}
">=" {colno += yyleng; if(flag){printf("GE\n");}}
">" {colno += yyleng; if(flag){printf("GT\n");}}
"{" {colno += yyleng; if(flag){printf("LBRACE\n");}}
"<=" {colno += yyleng; if(flag){printf("LE\n");}}
"(" {colno += yyleng; if(flag){printf("LPAR\n");}}
"[" {colno += yyleng; if(flag){printf("LSQ\n");}}
"<" {colno += yyleng; if(flag){printf("LT\n");}}
"-" {colno += yyleng; if(flag){printf("MINUS\n");}}
"%" {colno += yyleng; if(flag){printf("MOD\n");}}
"!=" {colno += yyleng; if(flag){printf("NE\n");}}
"!" {colno += yyleng; if(flag){printf("NOT\n");}}
"||" {colno += yyleng; if(flag){printf("OR\n");}}
"+" {colno += yyleng; if(flag){printf("PLUS\n");}}
"}" {colno += yyleng; if(flag){printf("RBRACE\n");}}
")" {colno += yyleng; if(flag){printf("RPAR\n");}}
"]" {colno += yyleng; if(flag){printf("RSQ\n");}}
"else" {colno += yyleng; if(flag){printf("ELSE\n");}}
"for" {colno += yyleng; if(flag){printf("FOR\n");}}
"if" {colno += yyleng; if(flag){printf("IF\n");}}
"var" {colno += yyleng; if(flag){printf("VAR\n");}}
"int" {colno += yyleng; if(flag){printf("INT\n");}}
"float32" {colno += yyleng; if(flag){printf("FLOAT32\n");}}
"bool" {colno += yyleng; if(flag){printf("BOOL\n");}}
"string" {colno += yyleng; if(flag){printf("STRING\n");}}
"fmt.Println" {colno += yyleng; if(flag){printf("PRINT\n");}}
"strconv.Atoi" {colno += yyleng; if(flag){printf("PARSEINT\n");}}
"func" {colno += yyleng; if(flag){printf("FUNC\n");}}
"os.Args" {colno += yyleng; if(flag){printf("CMDARGS\n");}}

"/*" {comment_begining_line = yylineno; comment_begining_column = colno;  colno += yyleng; BEGIN COMMENT1;}
"//" {comment_begining_line = yylineno; comment_begining_column = colno;  colno += yyleng; BEGIN COMMENT2;}
<COMMENT1>"*/" {colno += yyleng; BEGIN 0;}
<COMMENT1>\n ;
<COMMENT1><<EOF>> {BEGIN 0; printf("Line %d, column %d: unterminated comment\n", comment_begining_line, comment_begining_column);}

<COMMENT2>"\n" {BEGIN 0;}
<COMMENT1>.  colno += yyleng;
<COMMENT2>.  colno += yyleng;
<COMMENT2><<EOF>> {BEGIN 0;}

{INTLIT} {colno += yyleng; if(flag){printf("INTLIT(%s)\n", yytext);}}
{REALLIT} {colno += yyleng; if(flag){printf("REALLIT(%s)\n", yytext);}}
{ID} {colno += yyleng; if(flag){printf("ID(%s)\n", yytext);}}
{STRLIT}   {if(flag) {printf("STRLIT(%s)\n", yytext);}}
\n	        {colno = 0;};
\t          ;
" "         ;
.           {colno += yyleng; printf("Line %d, column %d: illegal character (%s)\n", yylineno, colno, yytext);}

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
