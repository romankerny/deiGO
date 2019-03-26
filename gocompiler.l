%option yylineno

%{
    #include <string.h>
    #include "structures.h"
    #include "y.tab.h"
    


    extern int flag;
    int colno = 0;
    int print_string = 1;
    int comment_beginning_line, comment_beginning_column;
    int string_beginning_line,  string_beginning_column;
    char str_beginning[1024];
    int semi = 0;
    int i = 0;
    int last_c = 0, last_l = 0;
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



%X              COMMENT1 COMMENT2 STRINGLIT

%%
{reserved} {semi = 0; colno += yyleng; if(flag){printf("RESERVED(%s)\n", yytext);} last_c = colno; last_l = yylineno; if(!flag) return RESERVED;}
";" {semi = 0; colno += yyleng; if(flag){printf("SEMICOLON\n");} last_c = colno; last_l = yylineno; if(!flag) return SEMICOLON;}
"_" {semi = 0; colno += yyleng; if(flag){printf("BLANKID\n");} last_c = colno; last_l = yylineno; if(!flag) return BLANKID;}
"package" {semi = 0; colno += yyleng; if(flag){printf("PACKAGE\n");} last_c = colno; last_l = yylineno; if(!flag) return PACKAGE;}
"return"  {semi = 1; colno += yyleng; if(flag){printf("RETURN\n");} last_c = colno; last_l = yylineno; if(!flag) return RETURN;}
"&&" {semi = 0; colno += yyleng; if(flag){printf("AND\n");} last_c = colno; last_l = yylineno; if(!flag) return AND;}
"=" {semi = 0; colno += yyleng; if(flag){printf("ASSIGN\n");} last_c = colno; last_l = yylineno; if(!flag) return ASSIGN;}
"*" {semi = 0; colno += yyleng; if(flag){printf("STAR\n");} last_c = colno; last_l = yylineno; if(!flag) return STAR;}
"," {semi = 0; colno += yyleng; if(flag){printf("COMMA\n");} last_c = colno; last_l = yylineno; if(!flag) return COMMA;}
"/" {semi = 0; colno += yyleng; if(flag){printf("DIV\n");} last_c = colno; last_l = yylineno; if(!flag) return DIV;}
"==" {semi = 0; colno += yyleng; if(flag){printf("EQ\n");} last_c = colno; last_l = yylineno; if(!flag) return EQ;}
">=" {semi = 0; colno += yyleng; if(flag){printf("GE\n");} last_c = colno; last_l = yylineno; if(!flag) return GE;}
">" {semi = 0; colno += yyleng; if(flag){printf("GT\n");} last_c = colno; last_l = yylineno; if(!flag) return GT;}
"{" {semi = 0; colno += yyleng; if(flag){printf("LBRACE\n");} last_c = colno; last_l = yylineno; if(!flag) return LBRACE;}
"<=" {semi = 0; colno += yyleng; if(flag){printf("LE\n");} last_c = colno; last_l = yylineno; if(!flag) return LE;}
"(" {semi = 0; colno += yyleng; if(flag){printf("LPAR\n");} last_c = colno; last_l = yylineno; if(!flag) return LPAR;}
"[" {semi = 0; colno += yyleng; if(flag){printf("LSQ\n");} last_c = colno; last_l = yylineno; if(!flag) return LSQ;}
"<" {semi = 0; colno += yyleng; if(flag){printf("LT\n");} last_c = colno; last_l = yylineno; if(!flag) return LT;}
"-" {semi = 0; colno += yyleng; if(flag){printf("MINUS\n");} last_c = colno; last_l = yylineno; if(!flag) return MINUS;}
"%" {semi = 0; colno += yyleng; if(flag){printf("MOD\n");} last_c = colno; last_l = yylineno; if(!flag) return MOD;}
"!=" {semi = 0; colno += yyleng; if(flag){printf("NE\n");} last_c = colno; last_l = yylineno; if(!flag) return NE;}
"!" {semi = 0; colno += yyleng; if(flag){printf("NOT\n");} last_c = colno; last_l = yylineno; if(!flag) return NOT;}
"||" {semi = 0; colno += yyleng; if(flag){printf("OR\n");} last_c = colno; last_l = yylineno; if(!flag) return OR;}
"+" {semi = 0; colno += yyleng; if(flag){printf("PLUS\n");} last_c = colno; last_l = yylineno; if(!flag) return PLUS;}
"}" {semi = 1; colno += yyleng; if(flag){printf("RBRACE\n");} last_c = colno; last_l = yylineno; if(!flag) return RBRACE;}
")" {semi = 1; colno += yyleng; if(flag){printf("RPAR\n");} last_c = colno; last_l = yylineno; if(!flag) return RPAR;}
"]" {semi = 1; colno += yyleng; if(flag){printf("RSQ\n");} last_c = colno; last_l = yylineno; if(!flag) return RSQ;}
"else" {semi = 0; colno += yyleng; if(flag){printf("ELSE\n");} last_c = colno; last_l = yylineno; if(!flag) return ELSE;}
"for" {semi = 0; colno += yyleng; if(flag){printf("FOR\n");} last_c = colno; last_l = yylineno; if(!flag) return FOR;}
"if" {semi = 0; colno += yyleng; if(flag){printf("IF\n");} last_c = colno; last_l = yylineno; if(!flag) return IF;}
"var" {semi = 0; colno += yyleng; if(flag){printf("VAR\n");} last_c = colno; last_l = yylineno; if(!flag) return VAR;}
"int" {semi = 0; colno += yyleng; if(flag){printf("INT\n");} last_c = colno; last_l = yylineno; if(!flag) return INT;}
"float32" {semi = 0; colno += yyleng; if(flag){printf("FLOAT32\n");} last_c = colno; last_l = yylineno; if(!flag) return FLOAT32;}
"bool" {semi = 0; colno += yyleng; if(flag){printf("BOOL\n");} last_c = colno; last_l = yylineno; if(!flag) return BOOL;}
"string" {semi = 0; colno += yyleng; if(flag){printf("STRING\n");} last_c = colno; last_l = yylineno; if(!flag) return STRING;}
"fmt.Println" {semi = 0; colno += yyleng; if(flag){printf("PRINT\n");} last_c = colno; last_l = yylineno; if(!flag) return PRINT;}
"strconv.Atoi" {semi = 0; colno += yyleng; if(flag){printf("PARSEINT\n");} last_c = colno; last_l = yylineno; if(!flag) return PARSEINT;}
"func" { semi = 0; colno += yyleng; if(flag){printf("FUNC\n");} last_c = colno; last_l = yylineno; if(!flag) return FUNC;}
"os.Args" {semi = 0; colno += yyleng; if(flag){printf("CMDARGS\n");} last_c = colno; last_l = yylineno; if(!flag) return CMDARGS;}





"/*"                {colno += yyleng; comment_beginning_line = yylineno; comment_beginning_column = colno-1; BEGIN COMMENT1;}
"//"                {comment_beginning_line = yylineno; comment_beginning_column = colno;  colno += yyleng; BEGIN COMMENT2;}
<COMMENT1>"*/"      {colno += yyleng; BEGIN 0;}
<COMMENT1>\n        {colno = 0;}
<COMMENT1><<EOF>>   {BEGIN 0; printf("Line %d, column %d: unterminated comment\n", comment_beginning_line, comment_beginning_column); }

<COMMENT2>\n        {colno = 0; BEGIN 0;}
<COMMENT1>.         {colno += yyleng;}
<COMMENT2>.         {colno += yyleng;}
<COMMENT2><<EOF>>   {BEGIN 0;}


{asp}                          {i = 0; colno += yyleng; last_c = colno; last_l = yylineno; string_beginning_column = colno; string_beginning_line = yylineno; print_string = 1; BEGIN STRINGLIT;}
<STRINGLIT>{asp}               {colno += yyleng; BEGIN 0; str_beginning[i] = '\0'; if(flag && print_string) {semi = 1; printf("STRLIT(\"%s\")\n", str_beginning);} yylval.s = strdup(str_beginning); if(!flag) return STRLIT;}
<STRINGLIT>{invalid_sequence}  {colno += yyleng; printf("Line %d, column %d: invalid escape sequence (%s)\n", yylineno, colno-1, yytext); print_string = 0; } 
<STRINGLIT>{valid_escape}      {colno += yyleng; str_beginning[i] = yytext[0]; i++; str_beginning[i] = yytext[1]; i++;}
<STRINGLIT>.                   {colno += yyleng; str_beginning[i] = *yytext; i++;}
<STRINGLIT>{STRLIT_forbbiden}  {colno += yyleng; BEGIN 0; printf("Line %d, column %d: unterminated string literal\n", string_beginning_line,  string_beginning_column); print_string = 0; colno = 0;}
<STRINGLIT><<EOF>>             {colno += yyleng; BEGIN 0; printf("Line %d, column %d: unterminated string literal\n", string_beginning_line, string_beginning_column);}


{INTLIT}   {semi = 1; colno += yyleng; if(flag){printf("INTLIT(%s)\n", yytext);} yylval.s=strdup(yytext); last_c = colno; last_l = yylineno; if(!flag) return INTLIT;}
{REALLIT}  {semi = 1; colno += yyleng; if(flag){printf("REALLIT(%s)\n", yytext);} yylval.s = strdup(yytext); last_c = colno; last_l = yylineno; if(!flag) return REALLIT;}
{ID}       {semi = 1; colno += yyleng; if(flag){printf("ID(%s)\n", yytext);} yylval.s = strdup(yytext); last_c = colno; last_l = yylineno; if(!flag) return ID;}
\n	       {if (semi && flag) printf("SEMICOLON\n"); colno = 0; if (semi) {semi = 0; if(!flag) return SEMICOLON;}}
\t         {colno += 4;}
" "        {colno += yyleng;}
.          {colno += yyleng; last_c = colno; last_l = yylineno; printf("Line %d, column %d: illegal character (%s)\n", yylineno, colno, yytext);}

%%

void yyerror (const char *s)
{

    if(yytext[0] == 0) {
        printf ("Line %d, column %d: syntax error: %s\n", last_l, (int) last_c+1, yytext);
    } else if (yytext[0] == '"')
        printf ("Line %d, column %d: syntax error: \"%s\"\n", string_beginning_line, string_beginning_column, str_beginning);
    else {
        printf ("Line %d, column %d: syntax error: %s\n", yylineno, (int) (colno - yyleng + 1), yytext);

    }
}

int yywrap()
{
    return 1;
}
