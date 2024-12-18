/* ----------------------------------------------------- */
/* --------------- Projeto de Compilador --------------- */
/* -------------- E5 de geração de código -------------- */
/* ----------------------------------------------------- */
/* -------- Integrantes --------------------------------

 Sofia Maciel D'avila - 00323829
 Yasmin Katerine Beer Zebrowski - 00277765
 
 */

%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>

int yylex(void);
void yyerror (char const *mensagem);
%}
%{

    extern int yylineno;
    extern void *arvore;
    extern struct table_stack *pilha;
    //int yydebug = 1;

%}

%code requires{ 
    #include "ast.h"
    #include "table.h"
    #include "iloc.h"
    #include "errors.h"
struct iloc_list* gera_instrucao_binaria(char* operacao, ast_t *operando1, ast_t *operando2, char* local);
}

%{    



%}

%union{
	struct value *valor_lexico;
	ast_t *nodo;
    enum data_types tipo;
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

%type<tipo> tipagem

%type<nodo> programa
%type<nodo> lista_de_funcoes   
%type<nodo> funcao
%type<nodo> cabecalho
%type<nodo> corpo
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
programa: criar_pilha empilha_tabela lista_de_funcoes desempilha_tabela {
    $$ = $3;
    arvore=$$;
}
| /* vazio */ {$$=NULL;arvore=$$;};

lista_de_funcoes: funcao lista_de_funcoes {
    $$=$1;
    ast_add_filho($$,$2);
    if($1!=NULL&&$2!=NULL){
        $$->instrucao=concatena_codigo($1->instrucao,$2->instrucao);
    }
}
| funcao {$$=$1;};

/* ---------------------- Não terminais para gerenciamento de escopo --------------------- */

empilha_tabela:{struct table *tabela = nova_tabela(); push(&pilha,tabela);}
desempilha_tabela:{pop(pilha);}
criar_pilha: {pilha = nova_pilha();}

/* --------------- Função --------------- */
funcao: cabecalho corpo desempilha_tabela {
    $$=$1;
    ast_add_filho($$,$2);
    if($2!=NULL){
    $$->instrucao = $2->instrucao;  }
};

cabecalho: TK_IDENTIFICADOR '=' empilha_tabela lista_de_parametros '>' tipagem {
    $$ = ast_new($1->valor);
    struct entry *func = busca_erro_semantico_tabela("",ERR_DECLARED,$1->valor,pilha->resto->topo);
    
    func = nova_entrada(FUNCAO,$6,$1); 
    add_entrada(pilha->resto->topo,func);
    
    $$->tipo = $6;

};

corpo: '{' lista_de_comandos '}' {$$=$2;};

lista_de_parametros: lista_de_parametros_nao_vazia | /*vazia*/;

lista_de_parametros_nao_vazia: lista_de_parametros_nao_vazia TK_OC_OR parametro | parametro;

parametro: TK_IDENTIFICADOR '<' '-' tipagem {
    char rotulo[100];
    sprintf(rotulo,"Erro na linha %d, parâmetro %s já declarado\n", yylineno, $1->valor);
    struct entry *param = busca_erro_semantico_tabela(rotulo,ERR_DECLARED,$1->valor,pilha->topo);

    param = nova_entrada(VARIAVEL,$4,$1);
    add_entrada(pilha->topo,param);
    
};

tipagem: TK_PR_INT {$$=INT;}
| TK_PR_FLOAT{$$=FLOAT;};

bloco_de_comandos: '{' empilha_tabela lista_de_comandos desempilha_tabela'}' {$$=$3;};

lista_de_comandos: comando lista_de_comandos{
    if($1!=NULL){
        $$=$1;
        /*se o campo next foi inicializado (no caso da declaracao_de_variavel), significa que o comando tem
        uma subarvore de comandos e que o proximo deve ser colocado ao fim dela*/
        if($$->prox!=NULL){ast_add_filho($$->prox,$2);
        } else{ast_add_filho($$,$2);}
        if($2!=NULL){
        $$->instrucao=concatena_codigo($1->instrucao,$2->instrucao);}
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
declaracao_de_variavel: tipagem lista_de_identificadores {
    if($2!=NULL){$2->tipo=$1;};
    $$=$2;
    atualiza_tipos_tabela(pilha->topo,$1);
    ast_prox($2,$2,3);
};

lista_de_identificadores: variavel ',' lista_de_identificadores{
    if($1!=NULL){
        $$=$1;ast_add_filho($$,$3);
    } else {
    $$=$3;}}
| variavel {if($1!=NULL){$$ = $1;}};

variavel: TK_IDENTIFICADOR {
    $$ = NULL;    
    struct entry *var = busca_erro_semantico_tabela("",ERR_DECLARED,$1->valor,pilha->topo);

    var = nova_entrada(VARIAVEL,UNDECLARED,$1);
    add_entrada(pilha->topo,var);
    
}
| TK_IDENTIFICADOR TK_OC_LE literal { 
    struct entry *var = busca_erro_semantico_tabela("",ERR_DECLARED,$1->valor,pilha->topo);

    $$ = ast_new("<=");
    $$->instrucao = $3->instrucao;  
    ast_t *l = ast_new($1->valor); 
    ast_add_filho($$,l);
    ast_add_filho($$,$3);
    var = nova_entrada(VARIAVEL,UNDECLARED,$1);
    add_entrada(pilha->topo,var);
    
};

literal: TK_LIT_INT {$$ = ast_new($1->valor); 
                     $$->tipo = INT;}
| TK_LIT_FLOAT      {$$ = ast_new($1->valor); 
                     $$->tipo = FLOAT;};

/* --------------- Comando de atribuição --------------- */
atribuicao: TK_IDENTIFICADOR '=' expressao {
    char rotulo[100];
    sprintf(rotulo,"Erro na linha %d, atribuição feita para variável não declarada\n", yylineno);
    struct entry *def = busca_erro_semantico_pilha(rotulo,ERR_UNDECLARED,1,$1->valor,(enum natures)NULL);
    sprintf(rotulo,"Erro na linha %d, atribuição feita para função\n",yylineno);
    busca_erro_semantico_pilha(rotulo,ERR_FUNCTION,1,$1->valor,VARIAVEL);

    $$ = ast_new("="); 
    $$->tipo=def->tipo; 
    ast_t *e = ast_new($1->valor); 
    e->tipo = def->tipo; 
    ast_add_filho($$,e);
    ast_add_filho($$,$3);
    struct iloc_list *i = gera_codigo("storeAI",$3->local,(char *)"rfp",def->deslocamento);
    $$->instrucao = concatena_codigo($3->instrucao,i);
    
    };


/* --------------- Chamada de função --------------- */
chamada_de_funcao: TK_IDENTIFICADOR '(' lista_de_argumentos ')' {
    int len = strlen($1->valor);
    char call[5+len]; 
    strcpy(call,"call "); 
    strcat(call,$1->valor); 
    
    char rotulo[100];
    sprintf(rotulo,"Erro na linha %d, função %s não existe\n", yylineno, $1->valor);
    struct entry *s = busca_erro_semantico_pilha(rotulo,ERR_UNDECLARED,1,$1->valor,(enum natures)NULL);
    sprintf(rotulo,"Erro na linha %d, %s não é uma função\n",yylineno,$1->valor);
    busca_erro_semantico_pilha(rotulo,ERR_VARIABLE,1,$1->valor,FUNCAO);

    $$=ast_new(call); 
    $$->tipo=s->tipo; 
    $$->instrucao = $3->instrucao;
    ast_add_filho($$,$3);
    
    };
lista_de_argumentos:  expressao {$$=$1;}
| expressao ',' lista_de_argumentos {
    $$=$1;
    ast_add_filho($$,$3);
    $$->instrucao=concatena_codigo($1->instrucao,$3->instrucao);
};


/* --------------- Comando de retorno --------------- */
retorno: TK_PR_RETURN expressao {
    $$=ast_new("return"); 
    ast_add_filho($$,$2);
    $$->instrucao = $2->instrucao;
};


/* --------------- Comandos de controle de fluxo --------------- */
controle_de_fluxo: condicional {$$ = $1;}
| iterativo {$$ = $1;};


/* --------------- Condicional --------------- */
condicional: TK_PR_IF '(' expressao ')' bloco_de_comandos condicional_else {
    $$=ast_new("if");
    ast_add_filho($$,$3);
    struct iloc_list *aux;
    char *t1 = gera_temp();
    struct iloc_list *load = gera_codigo("loadI","0",t1,NULL);
    aux=concatena_codigo($3->instrucao,load);
    char *t2 = gera_temp();
    struct iloc_list *cmp = gera_codigo("cmp_NE",t1,$3->local,t2);
    aux = concatena_codigo(aux,cmp);
    char *lf = gera_rotulo();
    char *lt = gera_rotulo();
    struct iloc_list *cbr = gera_codigo("cbr",t2,lt,lf);
    aux = concatena_codigo(aux,cbr);
    struct iloc_list *btrue = gera_codigo("nop",lt,NULL,NULL);
    aux = concatena_codigo(aux,btrue);
    if($5!=NULL){
        ast_add_filho($$,$5);
        aux = concatena_codigo(aux,$5->instrucao);
        };
    if($6!=NULL){
            ast_add_filho($$,$6);
            char *lj = gera_rotulo();
            struct iloc_list *jumpi = gera_codigo("jumpI",lj,NULL,NULL);
            aux = concatena_codigo(aux,jumpi);
            struct iloc_list *bfalse = gera_codigo("nop",lf,NULL,NULL);
            aux = concatena_codigo(aux,bfalse);
            aux = concatena_codigo(aux,$6->instrucao);
            struct iloc_list *bprox = gera_codigo("nop", lj, NULL,NULL);
            aux = concatena_codigo(aux,bprox);
            $$->instrucao = aux;
        } else{
            struct iloc_list *bfalse = gera_codigo("nop",lf,NULL,NULL);
            aux = concatena_codigo(aux,bfalse);
            $$->instrucao = aux;
        }
};

condicional_else: TK_PR_ELSE bloco_de_comandos {
    if($2!=NULL){
        $$=$2;
        $$->instrucao = $2->instrucao;
    }
}
| /*vazio*/ {$$=NULL;};


/* --------------- Iterativo --------------- */
iterativo: TK_PR_WHILE '(' expressao ')' bloco_de_comandos { 
    $$=ast_new("while"); 
    ast_add_filho($$,$3);
     struct iloc_list *aux;
     char *l1 = gera_rotulo();
     struct iloc_list *inicio = gera_codigo("nop", l1, NULL, NULL);
     aux = concatena_codigo(inicio,$3->instrucao);
     char *t1 = gera_temp();
     struct iloc_list *load = gera_codigo("loadI", "0", t1, NULL);
     aux = concatena_codigo(aux,load);
     char *t2 = gera_temp();
     struct iloc_list *cmp = gera_codigo("cmp_NE",t1,$3->local,t2);
     aux = concatena_codigo(aux, cmp);
     char *l2 = gera_rotulo();
     char *l3 = gera_rotulo();
     struct iloc_list *cbr = gera_codigo("cbr", t2, l2, l3);
     aux = concatena_codigo(aux,cbr);
     struct iloc_list *nop = gera_codigo("nop", l2, NULL, NULL);
     aux = concatena_codigo(aux,nop);
    if($5!=NULL){
        ast_add_filho($$,$5);
        aux = concatena_codigo(aux,$5->instrucao);
        }
    struct iloc_list *jumpi = gera_codigo("jumpI", l1, NULL, NULL);
    aux = concatena_codigo(aux,jumpi);
    struct iloc_list *fora = gera_codigo("nop", l3, NULL, NULL);
    aux = concatena_codigo(aux,fora);
    $$->instrucao = aux;
    };

/* --------------- Expressões --------------- */
expressao: expressao_or {$$ = $1;};

expressao_or: expressao_or TK_OC_OR expressao_and {
    $$ = ast_new("|"); 
    $$->tipo = inferencia_tipos($1->tipo,$3->tipo); 
    ast_add_filho($$, $1); 
    ast_add_filho($$, $3);
    $$->local = gera_temp();
    $$->instrucao = gera_instrucao_binaria("or",$1,$3,$$->local);
    }
| expressao_and {$$ = $1;};

expressao_and: expressao_and TK_OC_AND expressao_eq {
    $$ = ast_new("&"); 
    $$->tipo = inferencia_tipos($1->tipo,$3->tipo); 
    ast_add_filho($$, $1); 
    ast_add_filho($$, $3);
    $$->local = gera_temp();
    $$->instrucao = gera_instrucao_binaria("and",$1,$3,$$->local);
    }
| expressao_eq {$$ = $1;};

operador_eq: TK_OC_EQ {$$ = ast_new("==");}
| TK_OC_NE {$$ = ast_new("!=");};
expressao_eq: expressao_eq operador_eq expressao_comparacao {
    $$ = $2; 
    $$->tipo = inferencia_tipos($1->tipo,$3->tipo); 
    ast_add_filho($$, $1); 
    ast_add_filho($$, $3);
    $$->local = gera_temp();
    if(!strcmp($2->label,"==")){
        $$->instrucao = gera_instrucao_binaria("cmp_EQ",$1,$3,$$->local);
    } else if(!strcmp($2->label,"!=")){
        $$->instrucao = gera_instrucao_binaria("cmp_NE",$1,$3,$$->local);
    }
    }
| expressao_comparacao {$$ = $1;};

operador_comparacao: '<' {$$ = ast_new("<");}
| '>' {$$ = ast_new(">");}
| TK_OC_LE {$$ = ast_new("<=");}
| TK_OC_GE {$$ = ast_new(">=");};
expressao_comparacao: expressao_comparacao operador_comparacao expressao_soma {
    $$ = $2; 
    $$->tipo = inferencia_tipos($1->tipo,$3->tipo); 
    ast_add_filho($$, $1); 
    ast_add_filho($$, $3);

    $$->local = gera_temp();
    if(!strcmp($2->label,">")){
        $$->instrucao = gera_instrucao_binaria("cmp_GT",$1,$3,$$->local);
    } else if(!strcmp($2->label,"<")){
        $$->instrucao = gera_instrucao_binaria("cmp_LT",$1,$3,$$->local);
    } else if(!strcmp($2->label,"<=")){
        $$->instrucao = gera_instrucao_binaria("cmp_LE",$1,$3,$$->local);
    } else if(!strcmp($2->label,">=")){
        $$->instrucao = gera_instrucao_binaria("cmp_GE",$1,$3,$$->local);
    }
    }
| expressao_soma {$$ = $1;};

operador_soma: '+' {$$ = ast_new("+");}
| '-' {$$ = ast_new("-");};
expressao_soma: expressao_soma operador_soma expressao_multiplicacao {
    $$ = $2; 
    $$->tipo = inferencia_tipos($1->tipo,$3->tipo);
    ast_add_filho($$, $1); 
    ast_add_filho($$, $3);    
    $$->local = gera_temp();
    if(!strcmp($2->label,"+")){
        $$->instrucao = gera_instrucao_binaria("add",$1,$3,$$->local);
    } else if(!strcmp($2->label,"-")){
        $$->instrucao = gera_instrucao_binaria("sub",$1,$3,$$->local);
    }
    }
| expressao_multiplicacao {$$ = $1;};

operador_multiplicacao: '*' {$$ = ast_new("*");} 
| '/' {$$ = ast_new("/");}
| '%' {$$ = ast_new("%");};
expressao_multiplicacao: expressao_multiplicacao operador_multiplicacao expressao_unaria {
    $$ = $2; 
    $$->tipo = inferencia_tipos($1->tipo,$3->tipo);
    ast_add_filho($$, $1); 
    ast_add_filho($$, $3);
    $$->local = gera_temp();
    if(!strcmp($2->label,"*")){
      $$->instrucao = gera_instrucao_binaria("mult",$1,$3,$$->local);
    } else if(!strcmp($2->label,"/")){
      $$->instrucao = gera_instrucao_binaria("div",$1,$3,$$->local);
    } else {$$->instrucao = concatena_codigo($1->instrucao,$3->instrucao);}
    }
| expressao_unaria {$$ = $1;}; 

operador_unario: '!' {$$ = ast_new("!");}
| '-' {$$ = ast_new("-");}; 

expressao_unaria: operador_unario expressao_unaria {
    $$ = $1; 
    $$->tipo=$2->tipo; 
    ast_add_filho($$, $2);

    $$->local = gera_temp();
    if(!strcmp($1->label,"-")){
      struct iloc_list *i = gera_codigo("multI",$2->local,"-1",$$->local);
      $$->instrucao = concatena_codigo($2->instrucao,i);
    } else if(!strcmp($1->label,"!")){
      char *t1 = gera_temp();
      struct iloc_list *load = gera_codigo("loadI","0", t1, NULL);
      struct iloc_list *cmp = gera_codigo("cmp_EQ",$2->local,t1,$$->local);
      struct iloc_list *i = concatena_codigo(load,cmp);
      $$->instrucao = concatena_codigo($2->instrucao,i);
    }
    }
| expressao_parenteses {$$ = $1;};

expressao_parenteses: '(' expressao ')' {$$ = $2;}
| operando {$$ = $1;};

operando: 
TK_IDENTIFICADOR { 
    char rotulo[100];
    sprintf(rotulo,"Erro na linha %d, operador %s não declarado\n", yylineno,$1->valor);
    struct entry *s = busca_erro_semantico_pilha(rotulo,ERR_UNDECLARED,1,$1->valor,(enum natures)NULL);
    $$ = ast_new($1->valor);
    $$->tipo = s->tipo;
    $$->local = gera_temp();
    $$->instrucao = gera_codigo("loadAI","rfp",s->deslocamento,$$->local);
    }
        
| literal {
    $$ = $1;
    $$->local = gera_temp();
    $$->instrucao = gera_codigo("loadI",$$->label,$$->local, NULL);
    } 
| chamada_de_funcao {$$ = $1;};

%%

void yyerror(char const *mensagem)
{
    fprintf(stderr, "%s na linha %d \n", mensagem, yylineno);
}

struct iloc_list *gera_instrucao_binaria(char* operacao, ast_t *operando1, ast_t *operando2, char* local){
    struct iloc_list *i = gera_codigo(operacao,operando1->local,operando2->local,local);
    struct iloc_list *load = concatena_codigo(operando1->instrucao,operando2->instrucao);
    struct iloc_list *aux = concatena_codigo(load,i);
    return aux;
}
