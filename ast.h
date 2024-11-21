#ifndef _ARVORE_H_
#define _ARVORE_H_

enum token_types {
  IDENTIFICADOR,
  LITERAL
};

enum data_types {
  FLOAT = 2,
  INT = 1
};

struct value{
  int linha;
	enum token_types tipo;
	char *valor;
};

typedef struct ast {
  char *label;
  int numero_de_filhos;
  struct ast **filhos;
  struct ast *prox;
  enum data_types tipo;
} ast_t;

/*
 * Função ast_new, cria um nó sem filhos com o label informado.
 */
ast_t *ast_new(const char *label, enum data_types tipo);

/*
 * Função ast_prox, busca recursivamente o primeiro filho em arvore que tem menos filhos que informado e adiciona ao atributo prox
 */
void ast_prox(ast_t *arvore, ast_t *prox, int numero_de_filhos);

/*
 * Função asd_tree, libera recursivamente o nó e seus filhos.
 */
void ast_free(ast_t *arvore);

/*
 * Função ast_add_filho, adiciona child como filho de arvore.
 */
void ast_add_filho(ast_t *arvore, ast_t *child);

/*
 * Função novo_valor, cria um novo struct value
 */
struct value *novo_valor(int linha, enum token_types tipo, char *valor);

/*
 * Função asd_print, imprime a arvore
 */
void asd_print (ast_t *arvore);

enum data_types inferencia_tipos(enum data_types tipo1, enum data_types tipo2);

#endif //_ARVORE_H_
