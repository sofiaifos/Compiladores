#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "ast.h"
#define ARQUIVO_SAIDA "saida.dot"

struct value *novo_valor(int linha, enum token_types tipo, char *valor){
	struct value *novo = NULL;
  novo = calloc(1, sizeof(struct value));
	novo->linha = linha;
	novo->tipo = tipo;
	novo->valor = valor;
	return novo;
};


ast_t *ast_new(const char *label)
{
  ast_t *ret = NULL;
  ret = calloc(1, sizeof(ast_t));
  if (ret != NULL){
    ret->label = strdup(label);
    ret->numero_de_filhos = 0;
    ret->filhos = NULL;
    ret->prox = NULL;
  }
  return ret;
}

void ast_prox(ast_t *arvore, ast_t *prox, int numero_de_filhos)
{
  if(arvore != NULL && prox != NULL){
    prox->tipo = arvore->tipo;
    if(prox->numero_de_filhos<numero_de_filhos){
      arvore->prox=prox;
    } else if(prox->numero_de_filhos==numero_de_filhos){
      ast_prox(arvore,prox->filhos[numero_de_filhos-1],numero_de_filhos);
    } else {
      printf("ERROR:Numero de filhos maior do que informado");
    }
  }
}
void ast_free(ast_t *arvore)
{
  if (arvore != NULL){
    int i;
    for (i = 0; i < arvore->numero_de_filhos; i++){
      ast_free(arvore->filhos[i]);
    }
    free(arvore->filhos);
    free(arvore->label);
    free(arvore);
  }
}

void ast_add_filho(ast_t *arvore, ast_t *child)
{
  if (arvore != NULL && child != NULL){
    arvore->numero_de_filhos++;
    arvore->filhos = realloc(arvore->filhos, arvore->numero_de_filhos * sizeof(ast_t*));
    arvore->filhos[arvore->numero_de_filhos-1] = child;
  }
}


static void _asd_print (ast_t *arvore)
{
  int i;
  if (arvore != NULL){
    printf("  %p [label=\"%s\"];\n", arvore, arvore->label);
    for (i = 0; i < arvore->numero_de_filhos; i++){
      printf("  %p,%p\n", arvore, arvore->filhos[i]);
      _asd_print(arvore->filhos[i]);
    }
  }
}

void asd_print (ast_t *arvore)
{
  if (arvore != NULL){
    _asd_print (arvore);
  }
}

enum data_types inferencia_tipos(enum data_types tipo1, enum data_types tipo2){
  if(tipo2>tipo1){
    return tipo2;
  } else{
    return tipo1;
  }
}

void print_codigo(ast_t *arvore){
  struct iloc_list *codigo = arvore->instrucao;
    for(int i=0; i<codigo->num_instrucoes; i++){
        struct iloc *instrucao = codigo->instrucoes[i];
        char* operacao = instrucao->operacao;
       if(!(strcmp("storeAI",operacao))){
        printf("%s %s => %s, %s\n",operacao, instrucao->arg1, instrucao->arg2, instrucao->arg3);
       } else if(!(strcmp("loadI",operacao))){
        printf("%s %s => %s\n",operacao, instrucao->arg1, instrucao->arg2);
       } else if(!(strcmp("cmp_LT",operacao))||!(strcmp("cmp_LE",operacao))||!(strcmp("cmp_EQ",operacao))||!(strcmp("cmp_GE",operacao))||!(strcmp("cmp_GT",operacao))||!(strcmp("cmp_NE",operacao))){
        printf("%s %s, %s -> %s\n",operacao, instrucao->arg1, instrucao->arg2, instrucao->arg3);
       } else if(!strcmp("cbr",operacao)){
        printf("%s %s -> %s, %s\n",operacao, instrucao->arg1, instrucao->arg2, instrucao->arg3);
       } else if(!strcmp("nop",operacao)){
        printf("%s: ",instrucao->arg1);
       } else if(!strcmp("jumpI",operacao)){
        printf("%s -> %s\n",operacao, instrucao->arg1);
       } else if(!strcmp("add",operacao)||!strcmp("sub",operacao)||!strcmp("mult",operacao)||!strcmp("div",operacao)||!strcmp("multI",operacao)||!strcmp("and",operacao)||!strcmp("or",operacao)||!strcmp("loadAI",operacao)){
        printf("%s %s, %s => %s\n",operacao, instrucao->arg1, instrucao->arg2, instrucao->arg3);       
       }
    }
}
