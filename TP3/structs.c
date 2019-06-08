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

Conceito* getConceito(char* concName){
	return (Conceito *) g_hash_table_lookup(conceitos, concName);
}

Conceito* newConceito(char *name){
	Conceito *conceito = (Conceito *) malloc(sizeof(Conceito));
	conceito->name = strdup(name);
	conceito->relations = NULL;
	return conceito;
}

void initConceitos(){
	conceitos = g_hash_table_new(g_str_hash, g_str_equal);
}

void addConceito(char* conceitoKey){
	Conceito *conceito = getConceito(conceitoKey);
	if(!conceito){
		conceito = newConceito(conceitoKey);
		g_hash_table_insert(conceitos, conceito->name, conceito);
	}
}

Relations* newRelations(char* relName){
	Relations *relations = (Relations *) malloc(sizeof(Relations));
	relations->name = strdup(relName);
	relations->terms = NULL;
	return relations;
}

void addRelationTo(char* relName, char* concName);

GHashTable* getConceitos(){
	return conceitos;
}