#include <string.h>
#include <stdlib.h>
#include "table.h"

struct entry *nova_entrada(int linha, enum natures natureza, enum data_types tipo, char *valor){
    struct entry *ent = NULL;
    ent = calloc(1, sizeof(struct entry));
    if (ent != NULL){
        ent->linha = linha;
        ent->natureza = natureza;
        ent->tipo = tipo;
        ent->valor = strdup(valor);
    }
    return ent;
};

struct table *nova_tabela(){
    struct table *tabela = NULL;
    tabela = calloc(1, sizeof(struct table));
    tabela->entradas = NULL;
    tabela->numero_de_entradas = 0;
    return tabela;
};

void add_entrada(struct table *tabela, struct entry *entrada){
    if (tabela != NULL && entrada != NULL){
        tabela->numero_de_entradas++;
        tabela->entradas = realloc(tabela->entradas, tabela->numero_de_entradas * sizeof(struct entry));
        tabela->entradas[tabela->numero_de_entradas - 1] = entrada;
    }
};

struct table_stack *nova_pilha(){
    struct table_stack *pilha = NULL;
    pilha = calloc(1,sizeof(struct table_stack));
    if (pilha != NULL){
        pilha->topo = NULL;
        pilha->resto = NULL;
    }
    return pilha;
}

void push(struct table_stack **pilha, struct table *tabela){
    if(tabela!=NULL && pilha!=NULL){
        if((*pilha)->topo != NULL){
            struct table_stack *pilha_atualizada = nova_pilha();
            if (pilha_atualizada!=NULL){
                pilha_atualizada->topo = (*pilha)->topo;
                pilha_atualizada->resto = (*pilha)->resto;
                (*pilha)->resto = pilha_atualizada;
            }
        }
        (*pilha)->topo=tabela;
    }

};

void pop(struct table_stack *pilha){
    if(pilha!=NULL){
        free_tabela(pilha->topo);
        if(pilha->resto!=NULL){
            pilha->topo = pilha->resto->topo;
            pilha->resto = pilha->resto->resto; 
        } else {
            free(pilha);
            pilha=NULL;
        }
    }
};

void free_tabela(struct table *tabela){
    if(tabela!=NULL){
        for(int i = 0;i<tabela->numero_de_entradas;i++){
            free(tabela->entradas[i]);
        }
        free(tabela->entradas);
        free(tabela);
    }
};

void free_pilha(struct table_stack *pilha){
    if(pilha!=NULL){
        free_tabela(pilha->topo);
        free_pilha(pilha->resto);
        free(pilha);
    }
};

