%{
    #include <stdio.h>
int yylex(void);
void yyerror (char const *mensagem);
%}
%{
    extern int yylineno;
%}
%token TK_PR_INT
%token TK_PR_FLOAT
%token TK_PR_IF
%token TK_PR_ELSE
%token TK_PR_WHILE
%token TK_PR_RETURN
%token TK_OC_LE
%token TK_OC_GE
%token TK_OC_EQ
%token TK_OC_NE
%token TK_OC_AND
%token TK_OC_OR
%token TK_IDENTIFICADOR
%token TK_LIT_INT
%token TK_LIT_FLOAT
%token TK_ERRO

%define parse.error verbose

%%
/*
Um programa na linguagem é composto por uma
lista de funções, sendo esta lista opcional.
*/
programa: lista_de_funcoes | /* vazio */ ;

lista_de_funcoes: lista_de_funcoes funcao | funcao;

/*exemplo de header
nome = a <- int | b <- int | c <- float > float

exemplo de corpo
{bloco de comandos}
*/

funcao: cabecalho corpo;

cabecalho: nome_da_funcao '=' lista_de_parametros '>' tipagem;

corpo: bloco_de_comandos;

bloco_de_comandos: '{' lista_de_comandos '}';

nome_da_funcao: TK_IDENTIFICADOR;

lista_de_parametros: lista_de_parametros TK_OC_OR parametro | parametro | /*vazia*/;

parametro: TK_IDENTIFICADOR '<' '-' tipagem;

tipagem: TK_PR_INT | TK_PR_FLOAT;

lista_de_comandos: lista_de_comandos comando | /*vazio*/;

comando: comando_simples ';';

comando_simples: declaracao_de_variavel | atribuicao | chamada_de_funcao | retorno | controle_de_fluxo;

declaracao_de_variavel: tipagem lista_de_identificadores;

variavel: TK_IDENTIFICADOR | TK_IDENTIFICADOR TK_OC_LE literal;

lista_de_identificadores: variavel ',' lista_de_identificadores | variavel;

literal: TK_LIT_INT | TK_LIT_FLOAT;

atribuicao: TK_IDENTIFICADOR '=' expressao;

chamada_de_funcao: nome_da_funcao '(' lista_de_argumentos ')';

lista_de_argumentos:  expressao | lista_de_argumentos ',' expressao;

retorno: TK_PR_RETURN expressao;

controle_de_fluxo: condicional | iterativo;

condicional: TK_PR_IF '(' expressao ')' bloco_de_comandos condicional_else;  

condicional_else: TK_PR_ELSE bloco_de_comandos | /*vazio*/;

iterativo: TK_PR_WHILE '(' expressao ')' bloco_de_comandos;

expressao: expressao_or;

expressao_or: expressao_or TK_OC_OR expressao_and | expressao_and;

expressao_and: expressao_and TK_OC_AND expressao_eq | expressao_eq;

operador_eq: TK_OC_EQ | TK_OC_NE;

expressao_eq: expressao_eq operador_eq expressao_comparacao | expressao_comparacao;

operador_comparacao: '<' | '>' | TK_OC_LE | TK_OC_GE;

expressao_comparacao: expressao_comparacao operador_comparacao expressao_soma | expressao_soma;

operador_soma: '+' | '-';

expressao_soma: expressao_soma operador_soma expressao_multiplicacao | expressao_multiplicacao;

operador_multiplicacao: '*' | '/' | '%' ;

expressao_multiplicacao: expressao_multiplicacao operador_multiplicacao expressao_unaria | expressao_unaria;

operador_unario: '!' | '-'; 

expressao_unaria: operador_unario expressao_unaria | expressao_parentese;

expressao_parentese: '(' expressao ')' | operando;

operando: TK_IDENTIFICADOR | literal | chamada_de_funcao;




%%
void yyerror(char const *mensagem)
{
    fprintf(stderr, "%s na linha %d \n", mensagem, yylineno);
}
