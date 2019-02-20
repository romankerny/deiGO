%{
 
%}

%%
[0-9]+  {numints++;}
[0-9]+"."[0-9]+	;
.	;
\n	;
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
