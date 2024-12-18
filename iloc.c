#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "iloc.h"
#include "ast.h"

char* gera_rotulo(){
    static int rotulo_num = 1;
    int len = snprintf(NULL,0,"L%d",rotulo_num);
    char *rotulo = calloc(1,sizeof(char)*len);
    snprintf(rotulo,len+1,"L%d",rotulo_num);
    rotulo_num++;
    return rotulo;
}

char* gera_temp(){
    static int temp_num = 1;
    int len = snprintf(NULL,0,"%d",temp_num);
    char *temp = calloc(1,sizeof(char)*len+2);
    snprintf(temp,len+2,"r%d",temp_num);
    temp_num++;
    return temp;
}

struct iloc *nova_instrucao(char* operacao, char* arg1, char* arg2, char* arg3){
    struct iloc *novo = NULL;
    novo = calloc(1,sizeof(struct iloc));
    novo->operacao = operacao;
    novo->arg1 = arg1;
    novo->arg2 = arg2;
    novo->arg3 = arg3;
    return novo;
}

struct iloc_list *nova_lista_instrucoes(){
    struct iloc_list *novo = NULL;
    novo = calloc(1,sizeof(struct iloc_list));
    novo->instrucoes=NULL;
    novo->num_instrucoes=0;
    return novo;
}

void add_instrucao(struct iloc_list *lista, struct iloc *instrucao){
    if(lista != NULL && instrucao != NULL){
        lista->num_instrucoes++;
        lista->instrucoes=realloc(lista->instrucoes,sizeof(struct iloc*)*lista->num_instrucoes);
        lista->instrucoes[lista->num_instrucoes-1] = instrucao;
    }
}

struct iloc_list *gera_codigo(char* operacao, char* arg1, char* arg2, char* arg3){
    struct iloc_list *lista = nova_lista_instrucoes();
    struct iloc *instrucao = nova_instrucao(operacao,arg1,arg2,arg3);
    add_instrucao(lista,instrucao);
    return lista;
}

struct iloc_list *concatena_codigo(struct iloc_list *lista_instrucoes1, struct iloc_list *lista_instrucoes2){
    struct iloc_list *lista = nova_lista_instrucoes();
    if(lista_instrucoes1!=NULL){
    for(int i=0;i<lista_instrucoes1->num_instrucoes;i++){
        add_instrucao(lista,lista_instrucoes1->instrucoes[i]);
    }}
    if(lista_instrucoes2!=NULL){
    for(int i=0;i<lista_instrucoes2->num_instrucoes;i++){
        add_instrucao(lista,lista_instrucoes2->instrucoes[i]);
    }}
    return lista;
}

