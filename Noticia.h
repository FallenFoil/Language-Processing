#ifndef noticia_h
#define noticia_h


#include "stdio.h"
#include "stdlib.h"
#include "string.h"

typedef struct noticia *Noticia;
typedef struct tag *Tag;

Noticia initNoticia();//inicializa a noticia
Tag initTag(char *name);
void increment(Tag n);
void addId(Noticia x, char *Id);//adiciona um id á noticia
void addTitle(Noticia x, char *title);//adiciona um titulo á noticia
void addDate(Noticia x, char *date);//adiciona uma data á noticia
void addTag(Noticia x,char *tag);//adiciona uma tag á noticia
void addTxt(Noticia x, char *txt);//adiciona o texto á noticia
void addCategory(Noticia x, char *category);//adiciona uma categoria á noticia
void printNoticia(Noticia x);//imprime toda a informação de uma determinada noticia
void printTag(Tag x);
char* getId(Noticia x);//devolve o id de uma noticia

#endif