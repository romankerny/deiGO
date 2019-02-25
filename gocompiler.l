%option yylineno

%{
    int flag = 0;
    int colno = 0;
    int comment_beginning_line, comment_beginning_column;
    int string_beginning_line,  string_beginning_column;
    char * str_beginning;
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

STRLIT_forbbiden  (\n|\r)

invalid_sequence  \\[^(f|n|r|t|\"|\\)]
asp               \"



%X              COMMENT1 COMMENT2 STRING

%%
{reserved} {if(flag){printf("RESERVED(%s)\n", yytext);}}
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

"/*"                {colno += yyleng; comment_beginning_line = yylineno; comment_beginning_column = colno; BEGIN COMMENT1;}
"//"                {colno += yyleng; comment_beginning_line = yylineno; comment_beginning_column = colno;  colno += yyleng; BEGIN COMMENT2;}
<COMMENT1>"*/"      {colno += yyleng; BEGIN 0;}
<COMMENT1>\n        {colno += 0;}
<COMMENT1><<EOF>>   {colno += yyleng;BEGIN 0; printf("Line %d, column %d: unterminated comment\n", comment_beginning_line, comment_beginning_column + 1);}

<COMMENT2>\n        {colno += 0; BEGIN 0;}
<COMMENT1>.         {colno += yyleng;}
<COMMENT2>.         {colno += yyleng;}
<COMMENT2><<EOF>>   {colno += yyleng;BEGIN 0;}


{asp}                       {colno += yyleng; str_beginning = yytext; BEGIN STRING; string_beginning_column = colno; string_beginning_line = yylineno;}
<STRING>{asp}               {colno += yyleng; BEGIN 0; if(flag) {printf("STRLIT(%s)\n", str_beginning);}}
<STRING>.                   {colno += yyleng;}
<STRING>{invalid_sequence}  {colno += yyleng; BEGIN 0; printf("Line %d, column %d: invalid escape sequence (%s)\n", string_beginning_line, string_beginning_column, yytext);} 
<STRING>{STRLIT_forbbiden}  {colno += yyleng; BEGIN 0; printf("Line %d, column %d: unterminated string literal\n", string_beginning_line, string_beginning_column);}
<STRING><<EOF>>             {colno += yyleng; BEGIN 0; printf("Line %d, column %d: unterminated string literal\n",   string_beginning_line, string_beginning_column);}



{INTLIT}   {colno += yyleng; if(flag){printf("INTLIT(%s)\n", yytext);}}
{REALLIT}  {colno += yyleng; if(flag){printf("REALLIT(%s)\n", yytext);}}
{ID}       {colno += yyleng; if(flag){printf("ID(%s)\n", yytext);}}
\n	       {colno = 0;};
\t         {colno += yyleng;}
" "        {colno += yyleng;}
.          {colno += yyleng; printf("Line %d, column %d: illegal character (%s)\n", yylineno, colno, yytext);}

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
