#include "Noticia.h"




typedef struct noticia{

    char *id;//id
    char *title;//titulo
    char *category;//categoria
    char *date;//data
    char **tags;//conjunto de tags
    int lenght_tags;
    char *text;//texto

}* Noticia;

//Funções públicas
void addTitle(Noticia x, char *title);
void addDate(Noticia x, char *date);
void addTag(Noticia x,char *tag);
void addTxt(Noticia x, char *txt);
void addCategory(Noticia x, char *category);
void printAll(Noticia x);
char* getId(Noticia x);



//Implementação
Noticia initNoticia(){
    Noticia n = malloc(sizeof(struct noticia));
    n->tags = malloc(sizeof(char*)*1024);
    n->lenght_tags=0;
    n->title = NULL;
    n->date = NULL;
    n->text = NULL;
    n->id = NULL;

    return n;
}

void addId(Noticia x,char *t){
    x->id = strdup(t);
}

void addTitle(Noticia x,char *t){
    x->title = strdup(t);
}

void addDate(Noticia x,char *t){
    x->date = strdup(t);
}

void addTxt(Noticia x,char *t){
    x->text = strdup(t);
}

void addCategory(Noticia x,char *t){
    x->category = strdup(t);
}


void addTag(Noticia x,char *t){
    x->tags[x->lenght_tags++] = strdup(t);
}

void printAll(Noticia x){
    //imprime id
    if(x->id){
        printf("%s\n",x->id);
    }
    //imprime titulo
    if(x->title){
        printf("%s\n",x->title);
    }
    //imprime tags
    int i = 0;
    while(i<x->lenght_tags){
        printf("%s\n",x->tags[i++]);
    }
    //imprime data
    if(x->date){
        printf("%s\n",x->date);
    }
    //imprime categoria
    if(x->category){
        printf("%s\n",x->category);
    }
    //imprime txt
    if(x->text){
        printf("%s\n",x->text);
    }
}

char* getId(Noticia x){
    return x->id;
}

