#ifndef _TABELA_H_
#define _TABELA_H_

#include "ast.h"

enum natures {
    VARIAVEL,
    FUNCAO
};

struct entry {
    enum natures natureza;
    enum data_types tipo;
    struct value *valor_lex;
};

struct table{
    struct entry **entradas;
    int numero_de_entradas;
};

struct table_stack{
    struct table *topo;
    struct table_stack *resto;
};

struct entry *nova_entrada(enum natures natureza, enum data_types tipo, struct value *valor_lex);

struct table *nova_tabela();

void add_entrada(struct table *tabela, struct entry *entrada);

struct table_stack *nova_pilha();

void push(struct table_stack **pilha, struct table *tabela);

void pop(struct table_stack *pilha);

void free_tabela(struct table *tabela);

void free_pilha(struct table_stack *pilha);

void print_pilha(struct table_stack *pilha);

void atualiza_tipos_tabela(struct table *tabela, enum data_types tipo);

struct entry *search_tabela(struct table *tabela, char *valor);

struct entry *search_pilha(struct table_stack *pilha, char *valor);

#endif //_TABELA_H_