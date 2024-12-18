#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#include "table.h"
extern struct table_stack *pilha;
extern int yylineno;

struct entry *busca_erro_semantico_pilha(char *msg, int erro, int equals, char *valor, enum natures natureza){
    struct entry *s = calloc(1, sizeof(struct entry)); 
    s = search_pilha(pilha,valor);
    if(s!=NULL&&natureza!=(enum natures)NULL){
        if(s->natureza!=natureza){
            printf("%s",msg);
            exit(erro);
        }
    }
    if((s!=NULL) && !equals || !(s != NULL) && equals){
        printf("%s",msg);
        exit(erro);
    }
    return s;
}

struct entry *busca_erro_semantico_tabela(char *msg, int erro, char *valor, struct table *tabela){
    struct entry *s = calloc(1, sizeof(struct entry)); 
    s = search_tabela(tabela,valor);
    if(s!=NULL){
        if(strlen(msg)){
            printf("%s",msg);
        } else {
        printf("Erro na linha %d, identificador %s já declarado na linha %d\n", yylineno, s->valor_lex->valor, s->valor_lex->linha);}
        exit(erro);
    }
    return s;
}