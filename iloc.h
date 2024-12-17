#ifndef _INSTRUCAO_H_
#define _INSTRUCAO_H_

#include "ast.h"

struct iloc{
    char *operacao;
    char *arg1;
    char *arg2;
    char *arg3;
};

struct iloc_list
{
    struct iloc **instrucoes;
    int num_instrucoes;
};

char* gera_temp();
char* gera_rotulo();
struct iloc *nova_instrucao(char* operacao, char* arg1, char* arg2, char* arg3);

void add_instrucao(struct iloc_list *lista, struct iloc *instrucao);
struct iloc_list *gera_codigo(char* operacao, char* arg1, char* arg2, char* arg3);
struct iloc_list *concatena_codigo(struct iloc_list *lista_instrucoes1, struct iloc_list *lista_instrucoes2);
void print_codigo(struct iloc_list *codigo);

#endif //_INSTRUCAO_H_