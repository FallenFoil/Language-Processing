%{
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <glib.h>
#include "Noticia.h"

#define MB 1024

FILE *out;

GHashTable *tags;
GHashTable *noticias;
Noticia x;
char *tag;
char tagBuffer[1500];
int bufferLength;
int semId = 0;
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

\<pub\>                         { x = initNoticia();  BEGIN ARTIGO; }

<ARTIGO>"</pub>"                { if(getId(x))  {g_hash_table_insert(noticias,getId(x),x);}
                                  else{
                                    char* strId = malloc(16);
                                    sprintf(strId,"semId-%d", semId);
                                    semId++;
                                    addId(x,strId);
                                    g_hash_table_insert(noticias,getId(x),x);}
                                  BEGIN INITIAL; }
<ARTIGO>#TAG:                   { BEGIN TAGS; }
<ARTIGO>#DATE:                  { BEGIN DATE; }
<ARTIGO>#ID:\{                  { BEGIN ID; }
<ARTIGO>(.|\n)                  { }

<TAGS>"tag:{"                   { bufferLength=0; BEGIN TAG; }
<TAGS>"#ID:{"                   { BEGIN ID; }

<TAG>"}"[ \n]                   { tagBuffer[bufferLength++]='\0';
                                  tag = strdup(tagBuffer);
                                  addTag(x,tag);
                                  BEGIN TAGS; 
                                }
<TAG>.                          { tagBuffer[bufferLength++]=yytext[0]; }

<ID>"post-"[0-9]+               { yytext[yyleng]='\0'; char* str=strdup(yytext); addId(x,str);}
<ID>(\n)                        { BEGIN CATEGORY; }
<ID>.                           { }

<CATEGORY>.*                    { yytext[yyleng]='\0';addCategory(x,yytext); }
<CATEGORY>("\n\n")              { BEGIN TITLE; }

<TITLE>.*                       { yytext[yyleng]='\0'; addTitle(x,strdup(yytext)); }
<TITLE>(\n)                     { BEGIN ARTIGO; }

<DATE>(\n)                      { BEGIN TEXT; }
<DATE>.*                        { yytext[yyleng]='\0'; addDate(x,yytext+9); }

<TEXT>.*                        { addTxt(x,yytext, yyleng); }
<TEXT>[\n]{3,5}                 { endText(x); BEGIN ARTIGO; }

(.|\n)                          { }
%%


int yywrap(){
    return 1;
}

void criaTags(void *key,void *value,void *data){
    Noticia x = (Noticia) value;
    int i=0;char *tmp;
    
    while(i<getNumTags(x)){
        
        tmp = strdup(getTag(x,i));
        if(tmp!=NULL){
            gpointer find = g_hash_table_lookup(tags,tmp);

            if(!find){
                Tag n = initTag(tmp);
                tagBelongsNoticia(n, getId(x));
                g_hash_table_insert(tags,tmp,n);
            }
                else{
                    Tag n = (Tag) find;
                    tagBelongsNoticia(n, getId(x));
                    g_hash_table_insert(tags,tmp,n);
                } 

        }
        i++;
    }
}

void noticiasHTML(void *key,void *value, void *data){
    Noticia x = (Noticia) value;
    
    fprintf((FILE *) data,"\t\t<li><a href='%s.html'>%s</a></li>\n",getId(x),getTitle(x));

    char* filename = (char*) calloc(strlen(getId(x))+21, sizeof(char));
    strcpy(filename, "HTML/Noticias/");
    strcat(filename, getId(x));
    strcat(filename, ".html");
      
    char** tags = getTags(x);
       
    FILE *f = fopen(filename,"w");
    if(f == NULL){
        printf("Erro ao criar o ficheiro HTML com a noticia");              
    }
    else{
        fprintf(f, "<!DOCTYPE html>\n<html lang=\"en\">\n\t<head>\n\t\t<title> %s </title>\n\t\t<meta charset=\"UTF-8\">\n\t\t<meta name=\"description\" content=\"%s\">\n\t\t<link href=\"https://fonts.googleapis.com/css?family=Montserrat:400,700\" rel=\"stylesheet\">\n\t</head>\n\n\t<body style=\"font-family: 'Montserrat', sans-serif;background-color: rgb(200, 200, 200);padding-right: 1%% ; padding-left: 1%%\" >\n\t\t<h2>%s</h2>\n\n\t\t<h4>%s</h4>\n\n\t\t<h4>Categoria: %s</h4>\n\n\t\t<div>\n\t\t\t<h4>Tags:</h4>\n"
        , getId(x), getId(x), getTitle(x), getDate(x), getCategory(x));
           
        if(getNumTags(x)>0){
            fprintf(f, "\t\t\t<ul>\n");
            for (int i = 0; i < getNumTags(x); i++){
                fprintf(f, "\t\t\t\t<li>%s</li>\n", tags[i]);
            }
        }
        else{
            fprintf(f, "\t\t\t\tSem Tags\n");
        }
            
        fprintf(f, "\t\t\t</ul>\n\t\t</div>\n\n\t\t<br>\n\n\t\t<div style=\"padding-right: 5%% ; padding-left: 4%%\">\n\t\t\t<p> \n\t\t\t\t%s\n\t\t\t</p>\n\t\t</div>\n\t</body>\n</html>",  getTxt(x));
        }
        fclose(f);
}

void verifyTagName(char* tagFileName){
    for (int i = 0; tagFileName[i]!='\0'; ++i){
        if(tagFileName[i]=='/' || tagFileName[i]==' '){
            tagFileName[i]='-';
        }
    }
}

void tagsHTML(gpointer key, gpointer value, gpointer user_data){
    Tag t = (Tag) value;
    fprintf((FILE*) user_data, "\t\t\t<tr> <td> <a href=\"%s.html\">%s</a> </td> <td> %d </td> </tr>\n", (char*) key, (char*) key, getTagRep(t));
    
    char* tagname = strdup((char*) key);
    verifyTagName(tagname);

    char* tagFileName = malloc(strlen((char*) key) + 16);
    strcpy(tagFileName, "HTML/Tags/");
    strcat(tagFileName, tagname);
    strcat(tagFileName, ".html");

    FILE* tagFile = fopen(tagFileName, "w");
    if(tagFile == NULL){
        printf("%s ==> ", tagFileName);
        printf("Erro ao criar o ficheiro HTML com as noticias com uma certa Tag\n");              
    }
    else{
        fprintf(tagFile, "<!DOCTYPE html>\n<html lang=\"en\">\n\t<head>\n\t\t<title> %s </title>\n\t\t<meta charset=\"UTF-8\">\n\t\t<meta name=\"description\" content=\"%s\">\n\t\t<link href=\"https://fonts.googleapis.com/css?family=Montserrat:400,700\" rel=\"stylesheet\">\n\t</head>\n\n\t<body style=\"font-family: 'Montserrat', sans-serif;background-color: rgb(200, 200, 200);padding-right: 1%% ; padding-left: 1%%\">\n\t\t<ul>\n"
        , (char*) key, (char*) key);

        for (int i = 0; i < getTagRep(t); ++i){
            char* idNoticia = getIdNoticia(t, i);
            Noticia x = (Noticia) g_hash_table_lookup(noticias, idNoticia);
            char* titleNoticia = getTitle(x);
            fprintf(tagFile,"\t\t<li><a href='../Noticias/%s.html'>%s</a></li>\n", idNoticia, titleNoticia);
        }

        fprintf(tagFile, "\t\t</ul>\n\t</body>\n</html>");
        fclose(tagFile);
    }
}

int main(int argc, char *argv[]){
    
    noticias = g_hash_table_new(g_str_hash, g_int64_equal);
    tags = g_hash_table_new(g_str_hash,  g_str_equal);

    yyin = fopen("folha8.OUT.txt", "r");

    printf("Inicio da filtragem\n");

    yylex();

    
    printf("\n\nFim da filtragem\n\n");   

    g_hash_table_foreach(noticias,criaTags,NULL);
    
    //Criação dos ficheiros com as Noticias
    FILE *index = fopen("HTML/Noticias/index.html","w");
    if(index == NULL){
        printf("Erro ao criar o ficheiro HTML com as noticias");
    }
    else{
        fprintf(index,"<!DOCTYPE html>\n<html lang=\"en\">\n\t<head>\n\t\t<title> NULLticias </title>\n\t\t<meta charset=\"UTF-8\">\n\t\t<link href=\"https://fonts.googleapis.com/css?family=Montserrat:400,700\" rel=\"stylesheet\">\n\t</head>\n\n\t<body style=\"font-family: 'Montserrat', sans-serif;background-color: rgb(200, 200, 200);padding-right: 1%% ; padding-left: 1%%\">\n\t\t<ul>");
        
        g_hash_table_foreach(noticias,noticiasHTML,index);

        fprintf(index,"\n\t\t</ul>\n\t</body>\n</html>");
        fclose(index);
    }

    //Criação do ficheiro com todas as Tags, com links para as noticias, e as suas repetiçoes
    FILE* tagsFile = fopen("HTML/Tags/tags.html", "w");
    if(index == NULL){
        printf("Erro ao criar o ficheiro HTML com as Tags, com links para as noticias, e as suas repetições");      
    }
    else{
        fprintf(tagsFile,"<!DOCTYPE html>\n<html lang=\"en\">\n\t<head>\n\t\t<title> Tags </title>\n\t\t<meta charset=\"UTF-8\">\n\t\t<meta name=\"description\" content=\"Ocorrencias de tags\">\n\t\t<meta name=\"keywords\" content=\"Tags,Ocorrencias de Tags\">\n\t\t<link href=\"https://fonts.googleapis.com/css?family=Montserrat:400,700\" rel=\"stylesheet\">\n\t</head>\n\n\t<body style=\"font-family: 'Montserrat', sans-serif;background-color: rgb(200, 200, 200);padding-right: 1%% ; padding-left: 1%%\" >\n\t\t<table>\n\t\t\t<tr>\n\t\t\t\t<th>Tag</th> <th>Number of repetitions</th>\n\t\t\t</tr>\n");
        
        g_hash_table_foreach(tags, tagsHTML, tagsFile);

        fprintf(tagsFile, "\t\t</table>\n\t</body>\n</html>");
        fclose(tagsFile);
    }
    

    return 0;
}