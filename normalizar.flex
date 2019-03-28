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

char txt[100*MB] ;

FILE *out;

GHashTable *tags;
GHashTable *noticias;
Noticia x;
char *tag;
char tagBuffer[1500];
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

\<pub\>                         { x = initNoticia();  BEGIN ARTIGO; }

<ARTIGO>"</pub>"                { if(getId(x)) g_hash_table_insert(noticias,getId(x),x);
                                 else g_hash_table_insert(noticias,"Sem titulo",x);
                                BEGIN INITIAL;}
<ARTIGO>#TAG:                   { BEGIN TAGS; }
<ARTIGO>#DATE:                  { BEGIN DATE; }
<ARTIGO>#ID:\{					{ BEGIN ID; }
<ARTIGO>(.|\n)                  { ; }

<TAGS>"tag:{"                  	{ bufferLength=0; BEGIN TAG; }
<TAGS>"#ID:{"                   { BEGIN ID; }

<TAG>"}"[ \n]                   { tagBuffer[bufferLength++]='\0';
                                  tag = strdup(tagBuffer);
                                  addTag(x,tag);
                                  BEGIN TAGS; 
                                }
<TAG>.                          { tagBuffer[bufferLength++]=yytext[0]; }

<ID>"post-"[0-9]+               { yytext[yyleng]='\0'; char* str=strdup(yytext); addId(x,str);}
<ID>(\n)                        { BEGIN CATEGORY; }
<ID>.                           { ; }

<CATEGORY>.*                    {yytext[yyleng]='\0';addCategory(x,yytext); }
<CATEGORY>\n\n                  { BEGIN TITLE; }

<TITLE>.*                       { yytext[yyleng]='\0'; addTitle(x,strdup(yytext)); BEGIN ARTIGO; }

<DATE>(.*\n\n)                  { BEGIN TEXT; }
<DATE>.*                        { yytext[yyleng]='\0'; addDate(x,yytext+9); }

<TEXT>.*\n 						{ strcat(txt,yytext); }//texto está todo na variavel txt
<TEXT>\n{3,} 					{ addTxt(x,txt); strcpy(txt,""); BEGIN ARTIGO; }//adiciona o texto, recomeça o txt e volta para o artigo

(.|\n)                			{ ; }
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
                TagBelongsNoticia(n, getId(x));
                g_hash_table_insert(tags,tmp,n);
            }
                else{
                    Tag n = (Tag) find;
                    TagBelongsNoticia(n, getId(x));
                    g_hash_table_insert(tags,tmp,n);
                } 

        }
        i++;
    }
}

void aplicaHtml(void *key,void *value, void *data){
    Noticia x = (Noticia) value;
    
    fprintf((FILE *) data,"        <li><a href='%s.html'>%s</a></li>\n",getId(x),getTitle(x));

    if(getId(x) == NULL){
        printf("Noticia sem ID\n");
    }
    else{
        char* filename = (char*) calloc(strlen(getId(x))+21, sizeof(char));
        strcpy(filename, "HTML/Noticias/");
        strcat(filename, getId(x));
        strcat(filename, ".html");
        
        char** tags = getTags(x);
        
        FILE *f = fopen(filename,"w");
        if(f == NULL){
            perror("Error creating the HTML file");              
        }
        else{        
            fprintf(f, "<!DOCTYPE html>\n<html lang=\"en\">\n    <head>\n        <title> %s </title>\n        <meta charset=\"UTF-8\">\n        <meta name=\"description\" content=\"%s\">\n        <link href=\"https://fonts.googleapis.com/css?family=Montserrat:400,700\" rel=\"stylesheet\">\n    </head>\n\n    <body style=\"font-family: 'Montserrat', sans-serif;background-color: rgb(200, 200, 200);padding-right: 1%% ; padding-left: 1%%\" >\n        <h2>%s</h2>\n\n        <h4>%s</h4>\n\n\n        <h4>Categoria: %s</h4>\n\n        \n\n        <div>\n\n            <h4>Tags:</h4>\n"
            , getId(x), getId(x), getTitle(x), getDate(x), getCategory(x));
            
            if(getNumTags(x)>0){
                fprintf(f, "            <ul>\n");
                for (int i = 0; i < getNumTags(x); i++){
                    fprintf(f, "                <li>%s</li>\n", tags[i]);
                }
            }
            else{
                fprintf(f, "                Sem Tags\n");
            }
            
            fprintf(f, "            </ul>\n        </div>\n\n        <br>\n\n        <div style=\"padding-right: 5%% ; padding-left: 4%%\">\n            <p> \n                %s\n            </p>\n        </div>\n    </body>\n</html>",  getTxt(x));
        }
        fclose(f);
    }
}

void tagsNums(gpointer key, gpointer value, gpointer user_data){
	Tag t = (Tag) value;
	fprintf((FILE*) user_data, "<tr> <td> %s </td> <td> %d </td> </tr>\n", (char*) key, getTagRep(t));
}

int main(int argc, char *argv[]){
    
    noticias = g_hash_table_new(g_int64_hash, g_int64_equal);
    tags = g_hash_table_new(g_int64_hash, g_int64_equal);

    //yyin = fopen("folha8.OUT.txt", "r");

    printf("Inicio da filtragem\n");

    yylex();

    
    printf("\n\nFim da filtragem\n\n");   

    g_hash_table_foreach(noticias,criaTags,NULL);
    
    //Criação dos ficheiros com as Noticias
    FILE *index = fopen("HTML/Noticias/index.html","w");
    if(index == NULL){
      	perror("Error creating the HTML file");   
    	_exit(1);             
   	}
    fprintf(index,"<!DOCTYPE html>\n<html lang=\"en\">\n    <head>\n        <title> NULLticias </title>\n        <meta charset=\"UTF-8\">\n        <link href=\"https://fonts.googleapis.com/css?family=Montserrat:400,700\" rel=\"stylesheet\">\n    </head>\n\n    <body style=\"font-family: 'Montserrat', sans-serif;background-color: rgb(200, 200, 200);padding-right: 1%% ; padding-left: 1%%\" >\n      	<ul>");
    
    g_hash_table_foreach(noticias,aplicaHtml,index);

    fprintf(index,"\n        </ul>\n    </body>\n</html>");
    fclose(index);

    //Criação do ficheiro com todas as Tags e as suas repetiçoes
    FILE* tagsFile = fopen("HTML/Tags/tags.html", "w");
    if(index == NULL){
      	perror("Error creating the HTML file");   
    	_exit(1);             
   	}
    fprintf(tagsFile, "<!DOCTYPE html>\n<html lang=\"en\">\n    <head>\n        <title> Tags </title>\n        <meta charset=\"UTF-8\">\n        <meta name=\"description\" content=\"Ocorrencias de tags\">\n        <meta name=\"keywords\" content=\"Tags,Ocorrencias de Tags\">\n        <link href=\"https://fonts.googleapis.com/css?family=Montserrat:400,700\" rel=\"stylesheet\">\n    </head>\n\n    <body style=\"font-family: 'Montserrat', sans-serif;background-color: rgb(200, 200, 200);padding-right: 1%% ; padding-left: 1%%\" >\n        <table> \n        	<tr> <th>Tag</th> <th>Number of repetitions </th> </tr>");
    

    g_hash_table_foreach(tags, tagsNums, tagsFile);

    fprintf(tagsFile, "</table>\n</body>\n</html>");
    fclose(tagsFile);
    

    return 0;
}