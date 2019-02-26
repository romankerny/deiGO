%option yylineno

%{
    int flag = 0;
    int colno = 0;
    int print_string = 1;
    int comment_beginning_line, comment_beginning_column;
    int string_beginning_line,  string_beginning_column;
    char * str_beginning;
    int semi = 0;
%}
reserved break|case|chan|const|continue|default|defer|fallthrough|go|goto|import|interface|map|range|select|struct|switch|type|"++"|"--"

letter         [a-z]|[A-Z]|"_"

decimal_digit  [0-9]
octal_digit    [0-7]
hex_digit      [0-9]|[a-f]|[A-F]

ID             {letter}({letter}|{decimal_digit})*

INTLIT         {decimal_lit}|{octal_lit}|{hex_lit}
decimal_lit    [0-9]{decimal_digit}*|0
octal_lit      0{octal_digit}+
hex_lit        0("x"|"X"){hex_digit}{hex_digit}*


decimals       {decimal_digit}+
exponent       ("e"|"E")("+"|"-")?{decimals}
REALLIT        ({decimals}"."{decimals}?{exponent}?)|({decimals}{exponent})|("."{decimals}{exponent}?)

STRLIT_forbbiden  (\n|\r)

invalid_sequence  \\[^fnrt\"\\]
valid_escape      \\(f|n|r|t|\"|\\)

asp               \"



%X              COMMENT1 COMMENT2 STRING

%%
{reserved} {semi = 0; colno += yyleng; if(flag){printf("RESERVED(%s)\n", yytext);}}
";" {semi = 0; colno += yyleng; if(flag){printf("SEMICOLON\n");}}
"_" {semi = 0; colno += yyleng; if(flag){printf("BLANKID\n");}}
"package" {semi = 0; colno += yyleng; if(flag){printf("PACKAGE\n");}}
"return"  {semi = 1; colno += yyleng; if(flag){printf("RETURN\n");}}
"&&" {semi = 0; colno += yyleng; if(flag){printf("AND\n");}}
"=" {semi = 0; colno += yyleng; if(flag){printf("ASSIGN\n");}}
"*" {semi = 0; colno += yyleng; if(flag){printf("STAR\n");}}
"," {semi = 0; colno += yyleng; if(flag){printf("COMMA\n");}}
"/" {semi = 0; colno += yyleng; if(flag){printf("DIV\n");}}
"==" {semi = 0; colno += yyleng; if(flag){printf("EQ\n");}}
">=" {semi = 0; colno += yyleng; if(flag){printf("GE\n");}}
">" {semi = 0; colno += yyleng; if(flag){printf("GT\n");}}
"{" {semi = 0; colno += yyleng; if(flag){printf("LBRACE\n");}}
"<=" {semi = 0; colno += yyleng; if(flag){printf("LE\n");}}
"(" {semi = 0; colno += yyleng; if(flag){printf("LPAR\n");}}
"[" {semi = 0; colno += yyleng; if(flag){printf("LSQ\n");}}
"<" {semi = 0; colno += yyleng; if(flag){printf("LT\n");}}
"-" {semi = 0; colno += yyleng; if(flag){printf("MINUS\n");}}
"%" {semi = 0; colno += yyleng; if(flag){printf("MOD\n");}}
"!=" {semi = 0; colno += yyleng; if(flag){printf("NE\n");}}
"!" {semi = 0; colno += yyleng; if(flag){printf("NOT\n");}}
"||" {semi = 0; colno += yyleng; if(flag){printf("OR\n");}}
"+" {semi = 0; colno += yyleng; if(flag){printf("PLUS\n");}}
"}" {semi = 1; colno += yyleng; if(flag){printf("RBRACE\n");}}
")" {semi = 1; colno += yyleng; if(flag){printf("RPAR\n");}}
"]" {semi = 1; colno += yyleng; if(flag){printf("RSQ\n");}}
"else" {semi = 0; colno += yyleng; if(flag){printf("ELSE\n");}}
"for" {semi = 0; colno += yyleng; if(flag){printf("FOR\n");}}
"if" {semi = 0; colno += yyleng; if(flag){printf("IF\n");}}
"var" {semi = 0; colno += yyleng; if(flag){printf("VAR\n");}}
"int" {semi = 0; colno += yyleng; if(flag){printf("INT\n");}}
"float32" {semi = 0; colno += yyleng; if(flag){printf("FLOAT32\n");}}
"bool" {semi = 0; colno += yyleng; if(flag){printf("BOOL\n");}}
"string" {semi = 0; colno += yyleng; if(flag){printf("STRING\n");}}
"fmt.Println" {semi = 0; colno += yyleng; if(flag){printf("PRINT\n");}}
"strconv.Atoi" {semi = 0; colno += yyleng; if(flag){printf("PARSEINT\n");}}
"func" {semi = 0; semi = 0; colno += yyleng; if(flag){printf("FUNC\n");}}
"os.Args" {semi = 0; colno += yyleng; if(flag){printf("CMDARGS\n");}}





"/*"                {colno += yyleng; comment_beginning_line = yylineno; comment_beginning_column = colno-1; BEGIN COMMENT1;}
"//"                {comment_beginning_line = yylineno; comment_beginning_column = colno;  colno += yyleng; BEGIN COMMENT2;}
<COMMENT1>"*/"      {colno += yyleng; BEGIN 0;}
<COMMENT1>\n        {colno = 0;}
<COMMENT1><<EOF>>   {BEGIN 0; printf("Line %d, column %d: unterminated comment\n", comment_beginning_line, comment_beginning_column); }

<COMMENT2>\n        {colno = 0; BEGIN 0;}
<COMMENT1>.         {colno += yyleng;}
<COMMENT2>.         {colno += yyleng;}
<COMMENT2><<EOF>>   {BEGIN 0;}


{asp}                       {colno += yyleng; string_beginning_column = colno; string_beginning_line = yylineno; print_string = 1; str_beginning = yytext; BEGIN STRING;}
<STRING>{asp}               {colno += yyleng; BEGIN 0; if(flag && print_string) {semi = 1; printf("STRLIT(%s)\n", str_beginning);}}
<STRING>{invalid_sequence}  {colno += yyleng; printf("Line %d, column %d: invalid escape sequence (%s)\n", yylineno, colno-1, yytext); print_string = 0; } 
<STRING>{valid_escape}      {colno += yyleng;}
<STRING>.                   {colno += yyleng;}
<STRING>{STRLIT_forbbiden}  {colno += yyleng; BEGIN 0; printf("Line %d, column %d: unterminated string literal\n", string_beginning_line,  string_beginning_column); print_string = 0; colno = 0;}
<STRING><<EOF>>             {colno += yyleng; BEGIN 0; printf("Line %d, column %d: unterminated string literal\n", string_beginning_line, string_beginning_column);}


{INTLIT}   {semi = 1; colno += yyleng; if(flag){printf("INTLIT(%s)\n", yytext);}}
{REALLIT}  {semi = 1; colno += yyleng; if(flag){printf("REALLIT(%s)\n", yytext);}}
{ID}       {semi = 1; colno += yyleng; if(flag){printf("ID(%s)\n", yytext);}}
\n	       {if (semi) {printf("SEMICOLON\n"); }colno = 0; semi = 0;};
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
