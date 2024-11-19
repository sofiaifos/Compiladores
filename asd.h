#ifndef _ARVORE_H_
#define _ARVORE_H_

struct valor{
  int linha;
	char *tipo;
	char *valor;
};

typedef struct asd_tree {
  char *label;
  int number_of_children;
  struct asd_tree **children;
  struct asd_tree *next;
} asd_tree_t;

/*
 * Função asd_new, cria um nó sem filhos com o label informado.
 */
asd_tree_t *asd_new(const char *label);

/*
 * Função asd_next, busca recursivamente o primeiro filho em tree que tem menos filhos que informado e adiciona ao atributo next
 */
void asd_next(asd_tree_t *tree, asd_tree_t *next, int number_of_children);

/*
 * Função asd_tree, libera recursivamente o nó e seus filhos.
 */
void asd_free(asd_tree_t *tree);

/*
 * Função asd_add_child, adiciona child como filho de tree.
 */
void asd_add_child(asd_tree_t *tree, asd_tree_t *child);

/*
 * Função asd_print, imprime recursivamente a árvore.
 */
void asd_print(asd_tree_t *tree);

/*
 * Função novo_valor, cria um novo struct valor
 */
struct valor *novo_valor(int line_number, char *type, char *valor);

/*
 * Função asd_print_graphviz, idem, em formato DOT
 */
void asd_print_graphviz (asd_tree_t *tree);
#endif //_ARVORE_H_
