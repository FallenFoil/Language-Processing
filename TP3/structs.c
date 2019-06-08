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

Conceito* newConceito(char *name,GList *r){
	Conceito *conceito = (Conceito *) malloc(sizeof(Conceito));
	conceito->name = strdup(name);
	conceito->relations = r;
	return conceito;
}


void addConceito(Conceito *c, GHashTable *conceitos){
	
	if(!g_hash_table_contains(conceitos,c->name)){
		g_hash_table_insert(conceitos, c->name, c);
	}
}

Relations* newRelation(char* relName,GList *r){
	Relations *relations = (Relations *) malloc(sizeof(Relations));
	relations->name = strdup(relName);
	relations->terms = r;
	return relations;
}

GList* addRelationTo(Relations *r, GList *l){
	l = g_list_append(l,r);
	return l;
}

GList* addTermsTo(char *termo, GList *l){
	l = g_list_append(l,termo);
	return l;
}


void printTerms(void *data , void* user_data){
	char * termo = (char *)data;
	printf("%s; ",termo);
}

void printRelations(void *data , void* user_data){
	Relations *r = (Relations *) data;
	printf("%s   - ", r->name);
	g_list_foreach(r->terms, printTerms, NULL);
	printf("\n");
}

void printConceito(void *key,void *value,void *data){
	Conceito *x = (Conceito *) value;
	printf("Conceito = %s\n",x->name);

	g_list_foreach(x->relations,printRelations,NULL);
	printf("\n");
}
