#define ERR_UNDECLARED       10 //2.3
#define ERR_DECLARED         11 //2.3
#define ERR_VARIABLE         20 //2.4
#define ERR_FUNCTION         21 //2.4
#include "table.h"

/*busca erro semantico na tabela, se não encontra, retorna a entrada correspondente*/
struct entry *busca_erro_semantico_pilha(char *msg, int erro, int equals, char *valor, enum natures natureza);

struct entry *busca_erro_semantico_tabela(char *msg, int erro, char *valor, struct table *tabela);