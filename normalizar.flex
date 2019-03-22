%{
//escape 
//Serve para declarar variaveis ou bibliotecas
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <glib.h>
#include "Noticia.h"

#define MB 1024

char txt[1024*MB] ;

FILE *out;

GHashTable *tags;
GList *noticias;
Noticia x;
Tag aux;
char *tag;
char tagBuffer[150];
int bufferLength;

%}

%x ARTIGO
%x TAGS
%x TAG
%x DATE
%x ID
%x CATEGORY
%x TITLE
%x TEXT

%%

\<pub\>                         {x = initNoticia();  BEGIN ARTIGO;}//começo de uma nova noticia

<ARTIGO>"</pub>"                { noticias = g_list_append(noticias, x); BEGIN INITIAL;} //Não encontra com barra.Falar com César Adiciona a noticia á arvore
<ARTIGO>(.|\n)                  { ; }
<ARTIGO>#TAG:                   { BEGIN TAGS;}//encontra tag
<ARTIGO>#DATE:                  { BEGIN DATE;}//encontra data

<TAGS>" tag:{"                  { bufferLength=0; BEGIN TAG; }
<TAGS>"#ID:{"                   { BEGIN ID; }

<TAG>"}"                        { tagBuffer[bufferLength++]='\0';
                                  tag = strdup(tagBuffer);  
                                  addTag(x,tag);
                                  gpointer find = g_hash_table_lookup(tags,tag);

                                  if(!find){
                                      Tag n = initTag(tag);
                                      g_hash_table_insert(tags,tag,n);
                                  }
                                  else{
                                      Tag n = (Tag) find;
                                      increment(n);
                                      g_hash_table_insert(tags,tag,n);
                                  }
                                  BEGIN TAGS; 
                                }
<TAG>.                          { tagBuffer[bufferLength++]=yytext[0]; }

<ID>"post-"[0-9]+               { yytext[yyleng]='\0'; char* str=strdup(yytext); addId(x,str); }
<ID>\n                          { BEGIN CATEGORY; }
<ID>.                           { ; }

<CATEGORY>.*                    {yytext[yyleng]='\0';addCategory(x,yytext); }
<CATEGORY>\n\n                  { BEGIN TITLE; }

<TITLE>.*                       { yytext[yyleng]='\0'; addTitle(x,strdup(yytext)); BEGIN ARTIGO; }

<DATE>.*\n\n                    { BEGIN TEXT; }
<DATE>.*                        { yytext[yyleng]='\0'; addDate(x,yytext+9); }

<TEXT>.*\n { strcat(txt,yytext);}//texto está todo na variavel txt
<TEXT>\n{3,} {addTxt(x,txt); strcpy(txt,""); BEGIN ARTIGO;}//adiciona o texto, recomeça o txt e volta para o artigo

(.*) {;}//tudo o que não tiver entre pub é ignorado
(\n{3,}) {;}//linhas em branco extra são removidas
%%


int yywrap(){
    return 1;
}



void transverseList(void * value, void * data){

    Noticia x = (Noticia) value;
    printNoticia(x);
    
}

void transverseFunc(void * key, void * value, void * data){
    
    Tag aux = (Tag) value;
    printTag(aux);

}


void aplicaHtml(void *value, void *data){
    Noticia x = (Noticia) value;
   
    fprintf((FILE *) data,"        <li><a href='%s.html'>%s</a></li>\n",getId(x),getTitle(x));//transforma isto num titulo de ficheiro

    char filename[strlen(getId(x))+11];
    sprintf(filename,"HTML/%s.html",getId(x));

    char** tags = getTags(x);
    char* strTags = strdup(tags[0]);

    for(int i=1; i<getNumTags(x); i++){
        strTags = (char*) realloc(strTags, strlen(strTags)+strlen(getTags(x)[i])+2);
        strcat(strTags,",");
        strcat(strTags, getTags(x)[i]);
    }

    printf("%s\n", filename);
    
    /*
    FILE *f = fopen(filename,"w");
    fprintf(f, "<!DOCTYPE html>\n<html lang=\"en\">\n    <head>\n        <title> %s </title>\n        <meta charset=\"UTF-8\">\n        <meta name=\"description\" content=\"%s\">\n        <meta name=\"keywords\" content=\"%s\">\n        <link href=\"https://fonts.googleapis.com/css?family=Montserrat:400,700\" rel=\"stylesheet\">\n    </head>\n\n    <body style=\"font-family: 'Montserrat', sans-serif;background-color: rgb(200, 200, 200);padding-right: 1% ; padding-left: 1%\" >\n        <h2>%s</h2>\n\n        <h4>%s</h4>\n\n\n        <h4>Categoria: %s</h4>\n\n        \n\n        <div>\n\n            <h4>Tags:</h4>\n            <ul>\n"
    , getId(x), getId(x), strTags, getTitle(x), getDate(x), getCategory(x));

    for (int i = 0; i < getNumTags(x); i++){
        fprintf(f, "                <li>%s</li>\n", tags[i]);
    }
    
    fprintf(f, "            </ul>\n        </div>\n\n        <br>\n\n        <div style=\"padding-right: 5% ; padding-left: 4%\">\n            <p> \n                %s\n            </p>\n        </div>\n    </body>\n</html>",  getTxt(x));
    */
    yylex();
}



int main(int argc, char *argv[]){
    
    tags = g_hash_table_new(g_int64_hash, g_int64_equal);

    //yyin = fopen("folha8_Small.txt", "r");
    printf("Inicio da filtragem\n");

    yylex();

    printf("\n\nFim da filtragem\n\n");
    
    

    //g_hash_table_foreach(tags, transverseFunc , NULL );
    //g_list_foreach(noticias, transverseList , NULL);
    

    
    FILE *fptr = fopen("HTML/index.html","w");
    fprintf(fptr,"<!DOCTYPE html>\n<html lang=\"en\">\n    <head>\n        <meta charset=\"UTF-8\">\n    </head>\n\n    <body>\n\n      <ul>");

    if(fptr == NULL){
      perror("Error creating the HTML file");   
      _exit(1);             
   }
    
    g_list_foreach(noticias,aplicaHtml,fptr);

    fprintf(fptr,"\n        </ul>\n    </body>\n</html>");
    fclose(fptr);
    


    return 0;
}