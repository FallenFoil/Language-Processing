%{
#define YYDEBUG 0
 

 #include <stdio.h>
 #include <glib.h>
 #include "structs.h"
 int yyerror(char *s){ fprintf(stderr, "Erro:%s\n", s); return 0;}
 int yylex();
 GHashTable *conceitos;
 Conceito *c;
 Relations *r;

%}
%union{
	char *string;
    //char *option;
	//char[2] *optionArgs;
	//int optionNumber = 0;

}
%token OPT CONCEITO RELATION TERMO
%type <string> OPT RELATION args CONCEITO termos TERMO conceitos relations options thesaurus

%%

thesaurus: options conceitos											{printf("%s%s\n",$1,$2);}
	;

options: OPT args 														{asprintf(&$$,"%s - %s\n", $1, $2);}
		| options OPT args 												{asprintf(&$$,"%s - %s\n", $2, $3);}
		|																{ }
		;

args: RELATION   														{$$ = $1;}
	| args RELATION														{asprintf(&$$, "%s%s", $1, $2);}	 	
	;

conceitos: CONCEITO relations											{//c = newConceito($1);
																		 asprintf(&$$,"%s\n%s\n", $1, $2);}

		 | conceitos CONCEITO relations 								{//c = newConceito($1);
			 															 asprintf(&$$,"%s%s\n%s\n" , $1 , $2 ,$3);}
	 	 |																{$$ = " ";}
		 ;

relations: RELATION termos 												{asprintf(&$$, "%s - %s", $1, $2);}					
		 | relations RELATION termos  									{asprintf(&$$, "%s\n%s - %s", $1, $2 , $3);}
		 ;	

termos: TERMO ',' termos												{asprintf(&$$, "%s,%s", $1, $3);}
	  | TERMO 															{ $$ = $1;}
	  ;



%%
#include "lex.yy.c"
#include "structs.h"

int main(){
	#if YYDEBUG
        yydebug = 1;
    #endif
	
	conceitos = g_hash_table_new(g_str_hash, g_str_equal);
	Conceito *c = newConceito("coisas");
   	//rintf("Iniciar parse\n");
   	//yyparse();
   	//printf("Fim de parse\n");
   	return 0;
}
