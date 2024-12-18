#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "table.h"
#include "ast.h"

struct entry *nova_entrada(enum natures natureza, enum data_types tipo, struct value *valor_lex){
    struct entry *ent = NULL;
    ent = calloc(1, sizeof(struct entry));
    if (ent != NULL){
        ent->natureza = natureza;
        ent->tipo = tipo;
        ent->valor_lex=valor_lex;
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
        int len = snprintf(NULL,0,"%d",(int)sizeof(int)*tabela->numero_de_entradas);
        entrada->deslocamento = calloc(1,sizeof(char)*len);
        sprintf(entrada->deslocamento, "%d", (int)sizeof(int)*tabela->numero_de_entradas);
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

void print_pilha(struct table_stack *pilha){
    printf("-------------------\n");
    if(pilha->topo != NULL){
    for(int i=0;i<pilha->topo->numero_de_entradas;i++){
        printf("Linha: %d, Tipo: %d, Valor: %s\n", pilha->topo->entradas[i]->valor_lex->linha, pilha->topo->entradas[i]->tipo,pilha->topo->entradas[i]->valor_lex->valor);
    }}
    if(pilha->resto!=NULL){
        print_pilha(pilha->resto);
    }
}

struct entry *search_tabela(struct table *tabela, char *valor)
{
    if(tabela!=NULL&&valor!=NULL){
    for (int i = 0; i < tabela->numero_de_entradas; i++){
        if (tabela->entradas[i]->valor_lex != NULL){
            if (strcmp(tabela->entradas[i]->valor_lex->valor, valor) == 0){
                return tabela->entradas[i];
            }
        }
    }
    }
    return NULL;
}

void atualiza_tipos_tabela(struct table *tabela, enum data_types tipo){
    int i = 0;
     while(tabela->numero_de_entradas > i){
        if(tabela->entradas[i]->tipo == UNDECLARED){
            tabela->entradas[i]->tipo = tipo;
        }
        i++;
    }
}


struct entry *search_pilha(struct table_stack *pilha, char *valor){
    struct entry *resultado = calloc(1,sizeof(struct entry));
    if(pilha!=NULL && valor!=NULL){
        if(pilha->topo!=NULL){
            resultado = search_tabela(pilha->topo, valor);
            if (resultado != NULL){
                return resultado;
            }
        }
        if(pilha->resto!=NULL){
            return search_pilha(pilha->resto,valor);
        } else {
            return NULL;
        }
    } else {return NULL;}
}

