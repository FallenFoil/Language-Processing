%{
//escape 
//Serve para declarar variaveis ou bibliotecas
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <glib.h>
#include "Noticia.h"

#define MB 1024

char txt[1024*MB] ;



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


\<pub\> {ECHO; x = initNoticia(); BEGIN ARTIGO;}//começo de uma nova noticia

<ARTIGO>"</pub>" {ECHO; g_tree_insert(noticias, getId(x) , x); BEGIN INITIAL;} //Não encontra com barra.Falar com César Adiciona a noticia á arvore
<ARTIGO>(.|\n) {ECHO;}//imprime tudo o resto
<ARTIGO>#TAG: {ECHO; BEGIN TAG;}//encontra tag
<ARTIGO>#DATE: {ECHO; BEGIN DATE;}//encontra data

<TAG>tag:\{[A-Z\ a-z]*/\} {ECHO;tag = strdup(yytext+5);addTag(x,tag);
                             
                            gpointer find = g_hash_table_lookup(tags,tag);
                            if(!find){
                                Tag n = initTag(tag);
                                g_hash_table_insert(tags,tag,n);
                            }else{
                                Tag n = (Tag) find;
                                increment(n);
                                g_hash_table_insert(tags,tag,n);
                            }
}


<TAG>#ID: {ECHO; BEGIN ID;}//encontra id

<ID>post-[0-9]+ {ECHO;addId(x,yytext);}
<ID>\n {ECHO;BEGIN CATEGORY;}

<CATEGORY>.* {ECHO; addCategory(x,yytext);}
<CATEGORY>\n\n {ECHO; BEGIN TITLE;}

<TITLE>.* {ECHO; addTitle(x,yytext);BEGIN ARTIGO;}

<DATE>.*\n\n {ECHO; BEGIN TEXT;}
<DATE>.* {ECHO; addDate(x,yytext+9);}



<TEXT>.*\n {ECHO; strcat(txt,yytext);}//texto está todo na variavel txt
<TEXT>\n{3,} {addTxt(x,txt); strcpy(txt,""); printf("\n\n"); BEGIN ARTIGO;}//adiciona o texto, recomeça o txt e volta para o artigo





(.*) {;}//tudo o que não tiver entre pub é removido
(\n{3,}) {printf("\n\n");}//linhas em branco extra são removidas
%%


int yywrap(){
    return 1;
}

gint compareIds (gconstpointer name1, gconstpointer name2)
{
    printf("strcmp: %d\n", strcmp (name1, name2));
    return (strcmp (name1 , name2));
}

//uso transverseFunc para a arvore e a hashtable, daó o warning
void transverseFunc(void * key, void * value, void * data){

    char * info = data;

    if(strcmp(info,"tree")==0){
        Noticia x = (Noticia) value;
        printNoticia(x);
    }else{
       Tag aux = (Tag) value;
       printTag(aux);
    }

}


int main(int argc, char *argv[]){
    
    tags = g_hash_table_new(g_int64_hash, g_int64_equal);
    noticias = g_tree_new((GCompareFunc) compareIds);
    
    printf("Inicio da filtragem\n");

    yylex(); //invocar a função de conhecimento que ele vai gerar para janeiro e os outros

    printf("Fim da filtragem\n");

    g_hash_table_foreach(tags, transverseFunc , "hash" );
    //g_tree_foreach(noticias, transverseFunc , "tree");
    
    return 0;
}