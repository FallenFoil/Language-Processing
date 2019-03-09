%{
//escape 
//Serve para declarar variaveis ou bibliotecas
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include "Noticia.h"

Noticia x;

%}

%x ARTIGO
%x TAG
%x DATE
%x ID
%x CATEGORY
%x TITLE
%x TEXT

%%


\<pub\> {ECHO; x = initNoticia(); BEGIN ARTIGO;}

<ARTIGO>\</pub\> {ECHO; BEGIN INITIAL;}
<ARTIGO>\n{3,} {printf("\n\n");}//tira todas as linhas em branco desnecessárias
<ARTIGO>(.|\n) {ECHO;}//imprime tudo o resto
<ARTIGO>#TAG: {ECHO; BEGIN TAG;}
<ARTIGO>#DATE: {ECHO; BEGIN DATE;}

<TAG>tag:\{[A-Z a-z]* {ECHO;addTag(x,yytext+5);}
<TAG>#ID: {ECHO; BEGIN ID;}

<ID>post-[0-9]+ {ECHO;addId(x,yytext);}
<ID>\n {ECHO;BEGIN CATEGORY;}


<CATEGORY>.* {ECHO; addCategory(x,yytext);}
<CATEGORY>\n\n {ECHO; BEGIN TITLE;}

<TITLE>.* {ECHO; addTitle(x,yytext);BEGIN ARTIGO;}


<DATE>.* {ECHO; addDate(x,yytext+8);}
<DATE>\n\n {ECHO;printf("TEXTO\n");BEGIN TEXT;}

<TEXT>\^$ {ECHO;printf("1 found\n");}
<TEXT>(.*)\n\n {ECHO;printf("2 found\n");}
<TEXT>\n{3,} {BEGIN ARTIGO;}




(.*) {;}//tudo o que não tiver entre pub é removido
(\n{3,}) {printf("\n\n");}//linhas em branco extra são removidas
%%


int yywrap(){
    return 1;
}

int main(int argc, char *argv[]){
    

    printf("Inicio da filtragem\n");

    yylex(); //invocar a função de conhecimento que ele vai gerar para janeiro e os outros

    printf("Fim da filtragem\n");

    
    return 0;
}