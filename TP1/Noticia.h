#ifndef noticia_h
#define noticia_h


#include "stdio.h"
#include "stdlib.h"
#include "string.h"

typedef struct noticia *Noticia;
typedef struct tag *Tag;

//Noticia
Noticia initNoticia();
void addId(Noticia x, char *Id);
void addTitle(Noticia x, char *title);
void addDate(Noticia x, char *date);
void addTag(Noticia x,char *tag);
void addTxt(Noticia x, char *txt, int n);
void endText(Noticia x);
void addCategory(Noticia x, char *category);
char* getId(Noticia x);
char* getTitle(Noticia x);
char* getCategory(Noticia x);
char* getDate(Noticia x);
int getNumTags(Noticia x);
char* getTag(Noticia x,int index);
char** getTags(Noticia x);
char* getTxt(Noticia x);
void printNoticia(Noticia x);

//Tag
Tag initTag(char *name);
void tagBelongsNoticia(Tag n, char *noticia);
int getTagRep(Tag n);
char* getIdNoticia(Tag n, int i);
void printTag(Tag x);

#endif