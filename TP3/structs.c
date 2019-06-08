#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <glib.h>

GHashTable *conceitos;


typedef struct relation
{
	char *name;
	GList *terms;
} Relations;

typedef struct conceito
{
	char *name;
	GList *relations;

} Conceito;


/////////////////////////////// HTML ///////////////////////////////
void BEGIN_HTML(FILE* file, char* title){
	fprintf(file, "<!DOCTYPE html>\n<html lang=\"en\">\n\t<head>\n\t\t<title> %s </title>\n\t\t<meta charset=\"UTF-8\">\n\t\t<meta name=\"description\" \
		content=\"%s\">\n\t\t<link href=\"https://fonts.googleapis.com/css?family=Montserrat:400,700\" rel=\"stylesheet\">\n\t</head>\n\t \
		<body style=\"font-family: 'Montserrat', sans-serif;background-color: rgb(230, 230, 230);padding-right: 1%%;padding-left: 1%%\">\n", title, title);
}

void END_HTML(FILE* file){
	fprintf(file, "\n\t</body>\n</html>");
}

void printRelation(void* relation ,void *file){
	fprintf((FILE*)file, "Nome: %s\n", ((Relations*) relation)->name);
}

void printConceito(Conceito *conceito, FILE *file){
	fprintf(file, "<h1>Nome: %s</h1>\nRelações:\n", conceito->name);
	g_list_foreach(conceito->relations, printRelation, file);
}
/////////////////////////////// HTML ///////////////////////////////

void initConceitos(){
	conceitos = g_hash_table_new(g_str_hash, g_str_equal);
}

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

void printRel(void *data , void* user_data){
	Relations *r = (Relations *) data;
	printf("%s   - ", r->name);
	g_list_foreach(r->terms, printTerms, NULL);
	printf("\n");
}

void printCon(void *key,void *value,void *data){
	Conceito *x = (Conceito *) value;
	printf("Conceito = %s\n",x->name);

	g_list_foreach(x->relations,printRel,NULL);
	printf("\n");
}
