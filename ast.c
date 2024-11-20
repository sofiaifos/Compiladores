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
