#include <stdio.h>
#include "ast.h"
#include "table.h"
extern int yyparse(void);
extern int yylex_destroy(void);
void *arvore = NULL;
struct table_stack *pilha = NULL;
void exporta (void *arvore){
  asd_print(arvore);
};
int main (int argc, char **argv)
{
  int ret = yyparse(); 
  exporta (arvore);
  yylex_destroy();
  ast_free(arvore);
  return ret;
}
