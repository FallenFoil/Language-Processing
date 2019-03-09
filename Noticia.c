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

Noticia initNoticia(){
    Noticia n = malloc(sizeof(struct noticia));
    n->id = malloc(1024);
    n->title = malloc(1204);
    n->date = malloc(1204);
    n->text = malloc(1204);
    n->category = malloc(1204);
    n->tags = malloc(sizeof(char*)*1024);
    n->lenght_tags=0;

    return n;
}

void addId(Noticia x,char *t){
    strcpy(x->id,t);
}

void addTitle(Noticia x,char *t){
    strcpy(x->title,t);
}

void addDate(Noticia x,char *t){
    strcpy(x->date,t);
}

void addTxt(Noticia x,char *t){
    strcpy(x->text,t);
}

void addCategory(Noticia x,char *t){
    strcpy(x->category,t);
}


void addTag(Noticia x,char *t){
    x->tags[x->lenght_tags] = malloc(1024);
    strcpy(x->tags[x->lenght_tags],t);
    x->lenght_tags++;
}

//incompleto
void printAll(Noticia x){
    //imprime id
    printf("%s\n",x->id);
    //imprime titulo
    printf("%s\n",x->title);
    //imprime tags
    while(x->lenght_tags-1>=0){
        printf("%s\n",x->tags[x->lenght_tags-1]);
        x->lenght_tags--;
    }
    //imprime data
     printf("%s\n",x->date);
    //imprime categoria
     printf("%s\n",x->category);
    //imprime txt
     printf("%s\n",x->text);

}