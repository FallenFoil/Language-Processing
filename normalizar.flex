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

%%


"<pub>" {ECHO; x = initNoticia(); BEGIN ARTIGO;}

<ARTIGO>"</pub>" {ECHO; BEGIN INITIAL;}
<ARTIGO>\n{3,} {printf("\n\n");}//tira todas as linhas em branco desnecessárias
<ARTIGO>(.|\n) {ECHO;}
<ARTIGO>"#TAG:" {ECHO; BEGIN TAG;}


<TAG>"tag:{"[A-Z a-z]*\} {ECHO;addTag(x,yytext+5);}



"#ID:" {ECHO;BEGIN ID;}

(.*) {;}//tudo o que não tiver entre pub é removido
(\n{3,}) {printf("\n\n");}//linhas em branco extra são removidas
%%


int yywrap(){
    return 1;
}

int main(int argc, char *argv[]){
    

    Noticia x = initNoticia();
    addId(x,"dasdasdsa");
    addTag(x,"coisas");
    addTag(x,"ola");

    printAll(x);

    printf("Inicio da filtragem\n");

    //yylex(); //invocar a função de conhecimento que ele vai gerar para janeiro e os outros

    printf("Fim da filtragem\n");

    
    return 0;
}