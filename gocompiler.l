%{
 
%}
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
