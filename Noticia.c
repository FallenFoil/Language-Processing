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




//Implementação
Noticia initNoticia(){
    Noticia n = malloc(sizeof(struct noticia));
    n->tags = malloc(sizeof(char*)*1024);
    n->lenght_tags=0;

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
    printf("%s\n",x->id);
    //imprime titulo
    printf("%s\n",x->title);
    //imprime tags
    int i = 0;
    while(i<x->lenght_tags){
        printf("%s\n",x->tags[i++]);
    }
    //imprime data
     printf("%s\n",x->date);
    //imprime categoria
     printf("%s\n",x->category);
    //imprime txt
     printf("%s\n",x->text);

}
