#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <glib.h>

typedef struct relations
{
	char *name;
	GList *terms;
} Relations;

typedef struct conceito
{
	char *name;
	GList *relations;

} Conceito;

Conceito* getConceito(char* concName, GHashTable *conceitos){
	return (Conceito *) g_hash_table_lookup(conceitos, concName);
}

Conceito* newConceito(char *name){
	Conceito *conceito = (Conceito *) malloc(sizeof(Conceito));
	conceito->name = strdup(name);
	conceito->relations = NULL;
	return conceito;
}


void addConceito(Conceito *c, GHashTable *conceitos){
	
	if(!g_hash_table_contains(conceitos,c->name)){
		g_hash_table_insert(conceitos, c->name, c);
	}
}

Relations* newRelation(char* relName){
	Relations *relations = (Relations *) malloc(sizeof(Relations));
	relations->name = strdup(relName);
	relations->terms = NULL;
	return relations;
}

void addRelationTo(Relations *r, Conceito *c){
	c->relations= (GList *) g_list_append(c->relations,r);
}

void addTermsTo(char *termo, Relations *r){
	r->terms = (GList *) g_list_append(r->terms,termo);
}

