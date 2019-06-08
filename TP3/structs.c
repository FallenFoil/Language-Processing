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


void createHTML(){
GHashTableIter iter;
gpointer key, value;

g_hash_table_iter_init (&iter, conceitos);
while (g_hash_table_iter_next (&iter, &key, &value)){
	char filePath[100] = "./html/conceitos/";
	strcpy(filePath, key);
	FILE * myfd = fopen(filePath, "w");

    // do something with key and value
  }
}


void BEGIN_HTML(FILE* file, title){
	fprintf(file, "<!DOCTYPE html>\n<html lang=\"en\">\n\t<head>\n\t\t<title>");
	fprintf(file, title); 
	print "</title>\n\t\t<meta charset=\"UTF-8\">\n\t\t<meta name=\"description\" content=\"" > file
	print title > file
	print "\">\n\t\t<link href=\"https://fonts.googleapis.com/css?family=Montserrat:400,700\" rel=\"stylesheet\">\n\t</head>\n\t<body style=\"font-family: 'Montserrat', sans-serif;background-color: rgb(230, 230, 230);padding-right: 1%;padding-left: 1%\" >\n" > file
}

void END_HTML(FILE* file){
	print "\n\t</body>\n</html>" > file
}