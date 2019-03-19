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
GTree *noticias;
Noticia x;
Tag aux;
char *tag;

%}

%x ARTIGO
%x TAG
%x DATE
%x ID
%x CATEGORY
%x TITLE
%x TEXT

%%


\<pub\>                         { x = initNoticia(); BEGIN ARTIGO;}//começo de uma nova noticia

<ARTIGO>"</pub>"                { g_tree_insert(noticias, getId(x) , x); BEGIN INITIAL;} //Não encontra com barra.Falar com César Adiciona a noticia á arvore
<ARTIGO>(.|\n)                  { ; }//imprime tudo o resto
<ARTIGO>#TAG:                   { BEGIN TAG;}//encontra tag
<ARTIGO>#DATE:                  { BEGIN DATE;}//encontra data

<TAG>tag:\{[A-Z\ a-z]*/\}       {   yytext[yyleng] = '\0'; 
                                    tag = strdup(yytext+5);  
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
                                }

<TAG>#ID:                       { BEGIN ID; }//encontra id

<ID>post-[0-9]+                 { yytext[yyleng]='\0'; addId(x,yytext); }
<ID>\n                          { BEGIN CATEGORY; }

<CATEGORY>.*                    {yytext[yyleng]='\0';addCategory(x,yytext); }
<CATEGORY>\n\n                  { BEGIN TITLE; }

<TITLE>.*                       { yytext[yyleng]='\0'; addTitle(x,strdup(yytext)); BEGIN ARTIGO; }

<DATE>.*\n\n                    { BEGIN TEXT; }
<DATE>.*                        { yytext[yyleng]='\0'; addDate(x,yytext+9); }



<TEXT>.*\n { strcat(txt,yytext);}//texto está todo na variavel txt
<TEXT>\n{3,} {addTxt(x,txt); strcpy(txt,""); printf("\n\n"); BEGIN ARTIGO;}//adiciona o texto, recomeça o txt e volta para o artigo





(.*) {;}//tudo o que não tiver entre pub é ignorado
(\n{3,}) {printf("\n\n");}//linhas em branco extra são removidas
%%


int yywrap(){
    return 1;
}

gint compareIds (gconstpointer name1, gconstpointer name2){
    return (strcmp (name1 , name2));
}

//uso transverseFunc para a arvore e a hashtable, daó o warning
void transverseFunc(void * key, void * value, void *     data){

    char * info = data;

    if(strcmp(info,"tree")==0){
        Noticia x = (Noticia) value;
        printNoticia(x);
    }else{
       Tag aux = (Tag) value;
       printTag(aux);
    }
}


gboolean aplicaHtml(void *key, void *value, void *data){
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

    FILE *f = fopen(filename,"w");
    fprintf(f, "<!DOCTYPE html>\n<html lang=\"en\">\n    <head>\n        <title> %s </title>\n        <meta charset=\"UTF-8\">\n        <meta name=\"description\" content=\"%s\">\n        <meta name=\"keywords\" content=\"%s\">\n        <link href=\"https://fonts.googleapis.com/css?family=Montserrat:400,700\" rel=\"stylesheet\">\n    </head>\n\n    <body style=\"font-family: 'Montserrat', sans-serif;background-color: rgb(200, 200, 200);padding-right: 1% ; padding-left: 1%\" >\n        <h2>%s</h2>\n\n        <h4>%s</h4>\n\n\n        <h4>Categoria: %s</h4>\n\n        \n\n        <div>\n\n            <h4>Tags:</h4>\n            <ul>\n"
    , getId(x), getId(x), strTags, getTitle(x), getDate(x), getCategory(x));

    for (int i = 0; i < getNumTags(x); i++){
        fprintf(f, "                <li>%s</li>\n", tags[i]);
    }
    
    fprintf(f, "            </ul>\n        </div>\n\n        <br>\n\n        <div style=\"padding-right: 5% ; padding-left: 4%\">\n            <p> \n                %s\n            </p>\n        </div>\n    </body>\n</html>",  getTxt(x));

    //yyin = fopen(aux,"r");
    //out = fopen(f,"w");
    
    yylex();

    return TRUE;
}


int main(int argc, char *argv[]){
    
    tags = g_hash_table_new(g_int64_hash, g_int64_equal);
    noticias = g_tree_new((GCompareFunc) compareIds);
    
    printf("Inicio da filtragem\n");

    yylex(); //invocar a função de conhecimento que ele vai gerar para janeiro e os outros

    printf("\n\nFim da filtragem\n\n");

    //g_hash_table_foreach(tags, transverseFunc , "hash" );
    //g_tree_foreach(noticias, transverseFunc , "tree");
    

    //começa html
    FILE *fptr = fopen("HTML/index.html","w");
    fprintf(fptr,"<!DOCTYPE html>\n<html lang=\"en\">\n    <head>\n        <meta charset=\"UTF-8\">\n    </head>\n\n    <body>\n\n      <ul>");

    if(fptr == NULL){
      perror("Error creating the HTML file");   
      _exit(1);             
   }

    g_tree_foreach(noticias,aplicaHtml,fptr);
    fprintf(fptr,"\n        </ul>\n    </body>\n</html>");
    fclose(fptr);
    


    return 0;
}