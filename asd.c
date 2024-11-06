#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "asd.h"
#define ARQUIVO_SAIDA "saida.dot"

struct valor novo_valor(int line_number, char *type, char *valor){
	struct valor novo;
	novo.linha = line_number;
	novo.tipo = type;
	novo.valor = valor;
	return novo;
};


asd_tree_t *asd_new(const char *label)
{
  asd_tree_t *ret = NULL;
  ret = calloc(1, sizeof(asd_tree_t));
  if (ret != NULL){
    ret->label = strdup(label);
    ret->number_of_children = 0;
    ret->children = NULL;
  }
  return ret;
}

void asd_free(asd_tree_t *tree)
{
  if (tree != NULL){
    int i;
    for (i = 0; i < tree->number_of_children; i++){
      asd_free(tree->children[i]);
    }
    free(tree->children);
    free(tree->label);
    free(tree);
  }
}

void asd_add_child(asd_tree_t *tree, asd_tree_t *child)
{
  if (tree != NULL && child != NULL){
    tree->number_of_children++;
    tree->children = realloc(tree->children, tree->number_of_children * sizeof(asd_tree_t*));
    tree->children[tree->number_of_children-1] = child;
  }
}

static void _asd_print (FILE *foutput, asd_tree_t *tree, int profundidade)
{
  int i;
  if (tree != NULL){
    fprintf(foutput, "%d%*s: Nó '%s' tem %d filhos:\n", profundidade, profundidade*2, "", tree->label, tree->number_of_children);
    for (i = 0; i < tree->number_of_children; i++){
      _asd_print(foutput, tree->children[i], profundidade+1);
    }
  }
}

void asd_print(asd_tree_t *tree)
{
  FILE *foutput = stderr;
  if (tree != NULL){
    _asd_print(foutput, tree, 0);
  }else{
    printf("Erro: %s recebeu parâmetro tree = %p.\n", __FUNCTION__, tree);
  }
}

static void _asd_print_graphviz (asd_tree_t *tree)
{
  int i;
  if (tree != NULL){
    printf("  %p [label=\"%s\"];\n", tree, tree->label);
    for (i = 0; i < tree->number_of_children; i++){
      printf("  %p,%p\n", tree, tree->children[i]);
      _asd_print_graphviz(tree->children[i]);
    }
  }
}

void asd_print_graphviz(asd_tree_t *tree)
{
  if (tree != NULL){
    _asd_print_graphviz(tree);
  }
}
