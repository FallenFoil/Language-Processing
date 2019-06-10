#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <glib.h>
#include <unistd.h> 
#include <fcntl.h> 

pthread_mutex_t mutex;
int bool;
GList *options;
GHashTable *conceitos; //contem toda a informação
GHashTable *termsByRelation; //Chave = char* relação , value = List<List<char *>> termos da relacao
							 //EXEMPLO Chave BT , value = {{animal, cao}, {animal, gato}, {ser vivo, anima}} Não é obrigatório ser de cumprimento 2


typedef struct tuplo
{
	char *conceito;
	char *relacao;
} Tuplo;

typedef struct option
{
	char* name;
	char* rel1;
	char* rel2;
} Option;

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


void ERROR(char * message){
	fprintf(stderr, "%s\n", message);
	_exit(0);
}

/////////////////////////////// HTML ///////////////////////////////

void BEGIN_HTML(FILE* file, char* title){
	fprintf(file, "<!DOCTYPE html>\n<html lang=\"en\">\n\t<head>\n\t\t<title> %s </title>\n\t\t<meta charset=\"UTF-8\">\n\t\t<meta name=\"description\" \
		content=\"%s\">\n\t\t<link href=\"https://fonts.googleapis.com/css?family=Montserrat:400,700\" rel=\"stylesheet\">\n\t</head>\n\t \
		<body style=\"font-family: 'Montserrat', sans-serif;background-color: rgb(230, 230, 230);padding-right: 1%%;padding-left: 1%%\">\n", title, title);
}

void END_HTML(FILE* file){
	fprintf(file, "\n\t</body>\n</html>");
}

void printTerm(void* term, void* file){
	fprintf((FILE*)file, "<li>Term: %s</li>\n", (char*) term);
}

void printRelation(void* relation ,void *file){
	Relations* rel = (Relations*) relation;
	fprintf((FILE*)file, "<h4>Relação: %s</h4>\n", rel->name);
	fprintf(file, "<ul>\n");
	g_list_foreach(rel->terms, printTerm, file);
	fprintf(file, "</ul>\n");
}

void printTermsOfRelation(void* terms, void* file){
	g_list_foreach((GList *)terms, printTerm, file);
	fprintf(file, "<br/>\n");
}

void printRelationByTerms(Relations *rel, void* file){
	fprintf(file, "<h1>%s</h1>\n", rel -> name);
	fprintf(file, "<ul>\n");
	g_list_foreach(rel->terms, printTermsOfRelation, file);
	fprintf(file, "</ul>\n");
}

void printConceito(Conceito *conceito, FILE *file){
	fprintf(file, "<h1>Conceito: %s</h1>\n<h2>Relações:</h2>\n", conceito->name);
	g_list_foreach(conceito->relations, printRelation, file);
}

void printConceitos(){
	FILE* index = fopen("./html/conceitos/index.html", "w");
	BEGIN_HTML(index, "Index");

	GHashTableIter iter;
	gpointer key, value;
	g_hash_table_iter_init (&iter, conceitos);
	while (g_hash_table_iter_next (&iter, &key, &value)){
		char filePath[100] = "./html/conceitos/";
		strcat(filePath, key);
		strcat(filePath, ".html");
		FILE * file = fopen(filePath, "w");
		BEGIN_HTML(file, key);
		printConceito((Conceito *) value, file);
		fprintf(index, "<h1><a href=\"./%s.html\">%s</a></h1>\n", (char*)key, (char*)key);
		END_HTML(file);
		fclose(file);
  	}

  	END_HTML(index);
  	fclose(index);
}

void printRelations(){
	FILE* index = fopen("./html/relacoes/index.html", "w");
	BEGIN_HTML(index, "Index");

	GHashTableIter iter;
	gpointer key, value;
	g_hash_table_iter_init (&iter, termsByRelation);
	while (g_hash_table_iter_next (&iter, &key, &value)){
		char filePath[100] = "./html/relacoes/";
		strcat(filePath, key);
		strcat(filePath, ".html");
		FILE * file = fopen(filePath, "w");
		BEGIN_HTML(file, key);
		printRelationByTerms((Relations *) value, file);
		fprintf(index, "<h1><a href=\"./%s.html\">%s</a></h1>\n", (char*)key, (char*)key);
		END_HTML(file);
		fclose(file);
  	}

  	END_HTML(index);
  	fclose(index);
}

void printOption(void* option, void* file){
	FILE* index = (FILE*) file;
	Option *opt = (Option*)  option;
	fprintf(index, "<h2>%s", opt->name);
	if(opt->rel1 != NULL)
		fprintf(index, " %s\n", opt->rel1);
	if(opt->rel2 != NULL)
		fprintf(index, " %s\n", opt->rel2);
	fprintf(index, "</h2>\n");
}

void printOptions(FILE* index){
	g_list_foreach(options, printOption, index);
}

void createHTML(){
	FILE* index = fopen("./html/index.html", "w");
	BEGIN_HTML(index, "Index");

	printOptions(index);
	printConceitos();
	fprintf(index, "<h1><a href=\"./conceitos/index.html\">Conceitos</a></h1>\n");
	printRelations();
	fprintf(index, "<h1><a href=\"./relacoes/index.html\">Relações</a></h1>\n");
	fprintf(index, "<img src=\"graph.jpeg\" alt=\"Smiley face\" style=\"display: block; margin-left: auto; margin-right: auto;\" width=\"70%%\">");
	
  	END_HTML(index);
  	fclose(index);
}

/////////////////////////////// HTML ///////////////////////////////

/////////////////////////////// DOT  ///////////////////////////////
FILE* dot;

void printRelations_DOT(void* term, void* dados){
	char** conceitoERelacao = (char**) dados;
	fprintf(dot, "\"%s\"->\"%s\" [ label = \"%s\" ]\n", conceitoERelacao[0], (char*) term, conceitoERelacao[1]);
}

void printConceito_DOT(void* relation, void* father){
	Relations * rel = (Relations *) relation;
	char* conceito = (char *) father;
	char* conceitoERelacao[2];
	conceitoERelacao[0] = conceito;
	conceitoERelacao[1] = rel->name;
	g_list_foreach(rel->terms, printRelations_DOT, conceitoERelacao);
}

void createDOT(){
	char* dotFilePath = "./html/graph.gv";
	dot = fopen( dotFilePath , "w");

	fprintf(dot, "digraph Conceitos {\n");
	GHashTableIter iter;
	gpointer key, value;
	g_hash_table_iter_init (&iter, conceitos);
	while (g_hash_table_iter_next (&iter, &key, &value)){
		Conceito * conceito = (Conceito *) value;
		g_list_foreach(conceito->relations,printConceito_DOT, conceito->name);
	}
	fprintf(dot, "}");
	fclose(dot);

    char *cmd = "dot";
	char *argv[] = {"dot", "-Tjpeg", "-o", "./html/graph.jpeg", "./html/graph.gv", NULL };
	execvp(cmd, argv);
}


/////////////////////////////// DOT  ///////////////////////////////

////////////////////////////// Struct //////////////////////////////
void initConceitos(){
	conceitos = g_hash_table_new(g_str_hash, g_str_equal);
}

void initRelations(){
	termsByRelation = g_hash_table_new(g_str_hash, g_str_equal);
} 

void initOptions(){
	options = NULL;
}

void init(){
	initConceitos();
	initRelations();
	initOptions();
}

Conceito* getConceito(char* concName){
	return (Conceito *) g_hash_table_lookup(conceitos, concName);
}

Conceito* newConceito(char *name, GList *r){

	Conceito *conceito = NULL;

	//quando o conceito não existe
	if((conceito=g_hash_table_lookup(conceitos,name))==NULL){
		conceito = (Conceito *) malloc(sizeof(Conceito));
		conceito->name = strdup(name);
		conceito->relations = r;
		return conceito;
	//quando já existe
	}else{
		conceito->relations = g_list_concat(conceito->relations,r);
		return conceito;
	}
}


void addConceito(Conceito *c){
	printf("ADICIONANDO %s\n",c->name);
	if(!g_hash_table_contains(conceitos,c->name)){
		g_hash_table_insert(conceitos, c->name, c);
	}
}

Relations* newRelation(char* relName, GList *r){
	Relations *relations = (Relations *) malloc(sizeof(Relations));
	relations->name = strdup(relName);
	relations->terms = r;
	return relations;
}

void addTermsToRelations(Relations * rel){
	if(!g_hash_table_contains(termsByRelation,rel->name)){
		Relations * novaRel = newRelation(rel->name, NULL);
		novaRel->terms = g_list_append(novaRel->terms, rel->terms);
		g_hash_table_insert(termsByRelation, novaRel->name, novaRel);
	} else {
		Relations * allTermsFromRel = (Relations *)g_hash_table_lookup(termsByRelation, rel->name);
		allTermsFromRel->terms = g_list_append(allTermsFromRel->terms, rel->terms);
	}
}


GList* addRelationTo(Relations *r, GList *l){
	l = g_list_append(l,r);
	addTermsToRelations(r);
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

// retorna null se não houver
char* getInvis(char * rel){
	for(int i = 0; i < g_list_length(options); i++){
		Option * opt = g_list_nth_data(options, i);
		if(strcmp(opt->name, "invis") == 0){
			if(strcmp(rel, opt->rel1) == 0){
				if(opt->rel2 == NULL) ERROR("Invis requires 2 arguments");
				return opt->rel2;
			}
			if(strcmp(rel, opt->rel2) == 0){
				if(opt->rel1 == NULL) ERROR("Invis requires 2 arguments");
				return opt->rel1;
			}
		}
	}
	return NULL;			
}

//encontra no conceito2 um termo equivalente ao conceito1 e mete no cocneito1 a inversa da relação
void putRelation(char *conceito1, char *conceito2 , char *relation, GHashTable *conceito){


	Conceito *c1 = getConceito(conceito1);
	Conceito *c2 = getConceito(conceito2);
 
	if(c1==NULL) newConceito(conceito1,NULL);
	if(c2==NULL) newConceito(conceito2,NULL);


	//cria a relação para o conceito c1
	GList *l1 = NULL;
	l1 = g_list_append(l1,conceito2);
	
	Relations *r = newRelation(relation,l1);
	//nova relação adicionada
	c1->relations = g_list_append(c1->relations,r);
	
}

void Terms(void *data, void* user_data){
	//se algum termo já existir
	char *termo = data;
	Conceito *c ;
	Tuplo *t = user_data;

	//se já existir um conceito para este termo, que vai existir
	if((c=g_hash_table_lookup(conceitos,termo))!=NULL){
		//se os termos não forem iguais
		if(strcmp(termo,t->conceito)!=0){
			char * inversa = getInvis(t->relacao);
			if(inversa != NULL)
				putRelation(termo,t->conceito,getInvis(t->relacao),conceitos);
		}
	}
}

void lookTerms(void* data,void* user_data){
	Relations *r = data;
	char *conceito = user_data;

	Tuplo *t = malloc(sizeof(Tuplo));
	t->conceito = strdup(conceito);
	t->relacao = strdup(r->name);

	g_list_foreach( r->terms, Terms, t );
}

void searchTerms(char *conceito,GList *relations){
	g_list_foreach(relations,lookTerms,conceito);

}


Option* newOption(char* name, GList *relations){
	Option* option = (Option *) malloc(sizeof(Option));
	option->name = strdup(name);
	option->rel1 = (char *) g_list_nth_data(relations, 0);
	option->rel2 = (char *) g_list_nth_data(relations, 1);
	return option;
}

void addOption(char *name, GList* relations){
	Option* opt = newOption(name, relations);
	options = g_list_append(options, opt);
}
