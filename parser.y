/* ----------------------------------------------------- */
/* --------------- Projeto de Compilador --------------- */
/* --------------- E3 de criação de AST ---------------- */
/* ----------------------------------------------------- */
/* -------- Integrantes --------------------------------

 Sofia Maciel D'avila - 00323829
 Yasmin Katerine Beer Zebrowski - 00277765
 
 */

%{
    #include <stdio.h>
    #include <string.h>
int yylex(void);
void yyerror (char const *mensagem);
%}
%{
    extern int yylineno;
    extern void *arvore;
%}

%code requires{ 
    #include "asd.h"
}

%union{
	struct valor valor_lexico;
	asd_tree_t *nodo;
}

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
%token<valor_lexico> TK_IDENTIFICADOR
%token<valor_lexico> TK_LIT_INT
%token<valor_lexico> TK_LIT_FLOAT
%token TK_ERRO

%type<nodo> programa
%type<nodo> lista_de_funcoes   
%type<nodo> funcao
%type<nodo> cabecalho
%type<nodo> corpo
%type<nodo> nome_da_funcao
%type<nodo> bloco_de_comandos
%type<nodo> lista_de_comandos
%type<nodo> comando
%type<nodo> comando_simples
%type<nodo> declaracao_de_variavel
%type<nodo> atribuicao
%type<nodo> chamada_de_funcao
%type<nodo> retorno
%type<nodo> controle_de_fluxo
%type<nodo> lista_de_identificadores
%type<nodo> expressao
%type<nodo> variavel
%type<nodo> literal
%type<nodo> lista_de_argumentos
%type<nodo> condicional
%type<nodo> iterativo
%type<nodo> condicional_else
%type<nodo> expressao_and
%type<nodo> expressao_comparacao
%type<nodo> expressao_eq
%type<nodo> expressao_multiplicacao
%type<nodo> expressao_or
%type<nodo> expressao_parenteses
%type<nodo> expressao_soma
%type<nodo> expressao_unaria
%type<nodo> operando
%type<nodo> operador_comparacao
%type<nodo> operador_eq
%type<nodo> operador_multiplicacao
%type<nodo> operador_soma
%type<nodo> operador_unario

%define parse.error verbose

%%

/* --------------- Programa --------------- */
programa: lista_de_funcoes {$$ = $1;arvore=$$;}
| /* vazio */ {$$=NULL;arvore=$$;};

lista_de_funcoes: funcao lista_de_funcoes {$$=$1;asd_add_child($$,$2);}
| funcao {$$=$1;};


/* --------------- Função --------------- */
funcao: cabecalho corpo {$$=$1;asd_add_child($$,$2);};

cabecalho: nome_da_funcao '=' lista_de_parametros '>' tipagem {$$=$1;};
corpo: bloco_de_comandos {$$=$1;};

nome_da_funcao: TK_IDENTIFICADOR {$$ = asd_new($1.valor);};

lista_de_parametros: lista_de_parametros_nao_vazia | /*vazia*/;
lista_de_parametros_nao_vazia: lista_de_parametros_nao_vazia TK_OC_OR parametro | parametro ;
parametro: TK_IDENTIFICADOR '<' '-' tipagem;
tipagem: TK_PR_INT | TK_PR_FLOAT;

bloco_de_comandos: '{' lista_de_comandos '}' {$$=$2;};
lista_de_comandos: comando lista_de_comandos{
    if($1!=NULL){
        $$=$1;
        /*se o campo next foi inicializado (no caso da declaracao_de_variavel), significa que o comando tem
        uma subarvore de comandos e que o proximo deve ser colocado ao fim dela*/
        if($$->next!=NULL){asd_add_child($$->next,$2);
        } else{asd_add_child($$,$2);}
    }else{$$=$2;}}
| /*vazia*/ {$$ = NULL;};


/* --------------- Comandos simples --------------- */

comando: comando_simples ';' {$$ = $1;};

comando_simples: declaracao_de_variavel {if($1!=NULL){$$ = $1;}}
| atribuicao {$$ = $1;}
| chamada_de_funcao {$$ = $1;}
| retorno {$$ = $1;}
| controle_de_fluxo {$$ = $1;}
| bloco_de_comandos {if($1!=NULL){$$ = $1;}}; 


/* --------------- Declaração de variável --------------- */
declaracao_de_variavel: tipagem lista_de_identificadores {$$=$2;asd_next($2,$2,3);};

variavel: TK_IDENTIFICADOR {$$ = NULL;}
| TK_IDENTIFICADOR TK_OC_LE literal {$$ = asd_new("<="); asd_tree_t *l = asd_new($1.valor); asd_add_child($$,l);asd_add_child($$,$3);};
literal: TK_LIT_INT { $$ = asd_new($1.valor);}
| TK_LIT_FLOAT      { $$ = asd_new($1.valor);};

lista_de_identificadores: variavel ',' lista_de_identificadores{if($1!=NULL){$$=$1;asd_add_child($$,$3);}else {$$=$3;}}
| variavel {if($1!=NULL){$$ = $1;}};


/* --------------- Comando de atribuição --------------- */
atribuicao: TK_IDENTIFICADOR '=' expressao {$$ = asd_new("="); asd_tree_t *e = asd_new($1.valor); asd_add_child($$,e);asd_add_child($$,$3);};


/* --------------- Chamada de função --------------- */
chamada_de_funcao: nome_da_funcao '(' lista_de_argumentos ')' {int len = strlen($1->label);char call[5+len]; strcpy(call,"call "); strcat(call,$1->label);$$=asd_new(call); asd_add_child($$,$3);};
lista_de_argumentos:  expressao {$$=$1;}
| expressao ',' lista_de_argumentos {$$=$1;asd_add_child($$,$3);};


/* --------------- Comando de retorno --------------- */
retorno: TK_PR_RETURN expressao {$$=asd_new("return"); asd_add_child($$,$2);};


/* --------------- Comandos de controle de fluxo --------------- */
controle_de_fluxo: condicional {$$ = $1;}
| iterativo {$$ = $1;};


/* --------------- Condicional --------------- */
condicional: TK_PR_IF '(' expressao ')' bloco_de_comandos condicional_else {$$=asd_new("if");asd_add_child($$,$3);if($5!=NULL){asd_add_child($$,$5);};if($6!=NULL){asd_add_child($$,$6);}};  
condicional_else: TK_PR_ELSE bloco_de_comandos {if($2!=NULL){$$=$2;}}
| /*vazio*/ {$$=NULL;};


/* --------------- Iterativo --------------- */
iterativo: TK_PR_WHILE '(' expressao ')' bloco_de_comandos { $$=asd_new("while"); asd_add_child($$,$3); if($5!=NULL){asd_add_child($$,$5);}};


/* --------------- Expressões --------------- */
expressao: expressao_or {$$ = $1;};

expressao_or: expressao_or TK_OC_OR expressao_and {$$ = asd_new("|"); asd_add_child($$, $1); asd_add_child($$, $3);}
| expressao_and {$$ = $1;};

expressao_and: expressao_and TK_OC_AND expressao_eq {$$ = asd_new("&"); asd_add_child($$, $1); asd_add_child($$, $3);}
| expressao_eq {$$ = $1;};

operador_eq: TK_OC_EQ {$$ = asd_new("==");}
| TK_OC_NE {$$ = asd_new("!=");};
expressao_eq: expressao_eq operador_eq expressao_comparacao {$$ = $2; asd_add_child($$, $1); asd_add_child($$, $3);}
| expressao_comparacao {$$ = $1;};

operador_comparacao: '<' {$$ = asd_new("<");}
| '>' {$$ = asd_new(">");}
| TK_OC_LE {$$ = asd_new("<=");}
| TK_OC_GE {$$ = asd_new(">=");};
expressao_comparacao: expressao_comparacao operador_comparacao expressao_soma {$$ = $2; asd_add_child($$, $1); asd_add_child($$, $3);}
| expressao_soma {$$ = $1;};

operador_soma: '+' {$$ = asd_new("+");}
| '-' {$$ = asd_new("-");};
expressao_soma: expressao_soma operador_soma expressao_multiplicacao {$$ = $2; asd_add_child($$, $1); asd_add_child($$, $3);}
| expressao_multiplicacao {$$ = $1;};

operador_multiplicacao: '*' {$$ = asd_new("*");} 
| '/' {$$ = asd_new("/");}
| '%' {$$ = asd_new("%");};
expressao_multiplicacao: expressao_multiplicacao operador_multiplicacao expressao_unaria {$$ = $2; asd_add_child($$, $1); asd_add_child($$, $3);}
| expressao_unaria {$$ = $1;}; 

operador_unario: '!' {$$ = asd_new("!");}
| '-' {$$ = asd_new("-");}; 

expressao_unaria: operador_unario expressao_unaria {$$ = $1; asd_add_child($$, $2);}
| expressao_parenteses {$$ = $1;};

expressao_parenteses: '(' expressao ')' {$$ = $2;}
| operando {$$ = $1;};

operando: TK_IDENTIFICADOR { $$ = asd_new($1.valor); }
| literal {$$ = $1;} 
| chamada_de_funcao {$$ = $1;};

%%

void yyerror(char const *mensagem)
{
    fprintf(stderr, "%s na linha %d \n", mensagem, yylineno);
}
