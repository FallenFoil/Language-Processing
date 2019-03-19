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

typedef struct tag{   
    char *tag;//tag
    int rept;//contador
}* Tag;

//Funções públicas
Noticia initNoticia();
Tag initTag(char *name);
void addTitle(Noticia x, char *title);
void addDate(Noticia x, char *date);
void addTag(Noticia x,char *tag);
void addTxt(Noticia x, char *txt);
void addCategory(Noticia x, char *category);
void printNoticia(Noticia x);
void printTag(Tag x);
void increment(Tag n);
char* getId(Noticia x);
char* getTitle(Noticia x);
char* getCategory(Noticia x);
char* getDate(Noticia x);
int getNumTags(Noticia x);
char** getTags(Noticia x);
char* getTxt(Noticia x);





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

Tag initTag(char *name){
    Tag n = malloc(sizeof(struct tag));
    n->tag = strdup(name);
    n->rept=1;
    return n;
}

void increment(Tag n){
    n->rept++;
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

void printNoticia(Noticia x){
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

void printTag(Tag x){
    //imprime o nome
    if(x->tag){
        printf("%s  ->",x->tag);
    }
    //imprime o numero de repeticoes
    printf(" %d\n",x->rept);
}

char* getId(Noticia x){
    return x->id;
}

char* getTitle(Noticia x){
    return x->title;
}

char* getCategory(Noticia x){
    return x->category;
}

char* getDate(Noticia x){
    return x->date;
}

int getNumTags(Noticia x){
    return x->lenght_tags;
}

char** getTags(Noticia x){
    return x->tags;
}

char* getTxt(Noticia x){
    return x->text;
}