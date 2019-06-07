#include <stdio.h>
#include <stdlib.h>
#include <glib.h>

GHashTable *conceitos;

typedef struct relations
{
	char *name;
	GSList *terms;
} Relations;
typedef struct conceito
{
	char *name;
	GSList *relations;
} Conceito;


Conceito* newConceito(char *name){
	Conceito *conceito = (Conceito *) malloc(sizeof(Conceito));
	conceito->name = strdup(name);
	conceito->relations = NULL;
	return conceito;
}

void initConceitos(){
	conceitos = g_hash_table_new(g_str_hash, g_str_equal);
}