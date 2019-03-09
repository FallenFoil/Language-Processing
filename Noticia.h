#ifndef noticia_h
#define noticia_h


#include "stdio.h"
#include "stdlib.h"
#include "string.h"

typedef struct noticia *Noticia;


Noticia initNoticia();
void addId(Noticia x, char *Id);
void addTitle(Noticia x, char *title);
void addDate(Noticia x, char *date);
void addTag(Noticia x,char *tag);
void addTxt(Noticia x, char *txt);
void addCategory(Noticia x, char *category);
void printAll(Noticia x);

#endif