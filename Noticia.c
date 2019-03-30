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
    char **id_noticia;//noticias que contêm esta tag
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
void tagBelongsNoticia(Tag n, char *noticia);
int getTagRep(Tag n);
char* getIdNoticia(Tag n, int i);

char* getId(Noticia x);
char* getTitle(Noticia x);
char* getCategory(Noticia x);
char* getDate(Noticia x);
int getNumTags(Noticia x);
char** getTags(Noticia x);
char* getTxt(Noticia x);
char* getTag(Noticia x,int index);

//Implementação
Noticia initNoticia(){
    Noticia n = malloc(sizeof(struct noticia));
    n->tags = malloc(200*sizeof(char*));
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
    n->id_noticia= malloc(1024*10*sizeof(char*));
    n->rept=0;
    return n;
}

//noticia adicionada ao conjunto de tags
void tagBelongsNoticia(Tag n, char *noticia){
    n->id_noticia[n->rept] = strdup(noticia);
    n->rept++;
}

int getTagRep(Tag n){
    return n->rept;
}

char* getIdNoticia(Tag n, int i){
    return n->id_noticia[i];
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
        printf("Id: %s\n",x->id);
    }
    //imprime titulo
    if(x->title){
        printf("title: %s\n",x->title);
    }
    //imprime tags
    int i = 0;
    printf("Tags:\n");
    while(i<x->lenght_tags){
        printf("-%s\n",x->tags[i++]);
    }
    //imprime data
    if(x->date){
        printf("Date: %s\n",x->date);
    }
    //imprime categoria
    if(x->category){
        printf("Category: %s\n",x->category);
    }
    //imprime txt
    if(x->text){
        printf("Text: %s\n",x->text);
    }
}

void printTag(Tag x){
    //imprime o nome
    if(x->tag){
        printf("%s  ->",x->tag);
    }
    //imprime o numero de repeticoes
    printf(" %d\n",x->rept);
    
    while(x->rept>0){
        printf("%s\n",x->id_noticia[x->rept]);
        x->rept--;
    }
}



//Gets e Sets para a Noticia
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

char* getTag(Noticia x,int index){
    return x->tags[index];
}

char** getTags(Noticia x){
    return x->tags;
}

char* getTxt(Noticia x){
    return x->text;
}