/*INTEGRANTES

 Sofia Maciel Davila - 00323829
 Yasmin Katerine Beer Zebrowski - 00277765
*/

%{
    #include "parser.tab.h"
%}

%option noyywrap
%option yylineno

%%

int return TK_PR_INT;
float return TK_PR_FLOAT;
if return TK_PR_IF;
else return TK_PR_ELSE;
while return TK_PR_WHILE;
return return TK_PR_RETURN;
"<=" return TK_OC_LE;
">=" return TK_OC_GE;
"==" return TK_OC_EQ;
"!=" return TK_OC_NE;
"&" return TK_OC_AND;
"|" return TK_OC_OR;
[-|!|*|/|%|+|<|>|{|}|(|)|=|,|;] return yytext[0];
[0-9]+ {yylval.valor_lexico = novo_valor(yylineno, "literal", strdup(yytext)); return TK_LIT_INT;}
[0-9]*"."[0-9]+ {yylval.valor_lexico = novo_valor(yylineno, "literal", strdup(yytext)); return TK_LIT_FLOAT;}
(_|[a-z])(_|[a-z]|[0-9])* {yylval.valor_lexico = novo_valor(yylineno, "identificador", strdup(yytext)); return TK_IDENTIFICADOR};
"//"[^\n]*|" "|"\n"|"\t" { };
. return TK_ERRO;
%%

int get_line_number(void){
    return yylineno;
}

struct valor novo_valor(int line_number, char *type, char *valor){
	struct valor novo;
	novo.linha = line_number;
	novo.tipo = type;
	novo.valor = valor;
	return novo;
}

