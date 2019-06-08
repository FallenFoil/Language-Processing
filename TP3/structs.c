#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <glib.h>

GHashTable *conceitos;

typedef struct relations
{
	char *name;
	GList *terms;
} Relation;

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
	fprintf((FILE*)file, "Nome: %s\n", ((Relation*) relation)->name);
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

Relation* newRelation(char* relName){
	Relation *relations = (Relation *) malloc(sizeof(Relation));
	relations->name = strdup(relName);
	relations->terms = NULL;
	return relations;
}

void addRelationTo(Relation *r, Conceito *c){
	c->relations= (GList *) g_list_append(c->relations,r);
}

void addTermsTo(char *termo, Relation *r){
	r->terms = (GList *) g_list_append(r->terms,termo);
}

GHashTable* getConceitos(){
	return conceitos;
}


void createHTML(){
GHashTableIter iter;
gpointer key, value;

g_hash_table_iter_init (&iter, conceitos);
while (g_hash_table_iter_next (&iter, &key, &value)){
	char filePath[100] = "./html/conceitos/";
	strcpy(filePath, key);	
	FILE *file = fopen(filePath, "w");
	BEGIN_HTML(file, key);
	Conceito *conceito = (Conceito*) value;
	printConceito(conceito, file);
	END_HTML(file);
    fclose(file);
  }
}

