%{
#define YYDEBUG 0
 #include <stdio.h>
 #include <glib.h>
 #include "structs.c"
 int yyerror(char *s){ fprintf(stderr, "Erro:%s\n", s); return 0;}
 int yylex();
 
 GList *terms = NULL;
 GList *relations = NULL;
 GList *rel4Opts = NULL;
 Conceito *c;
 char *c1;
 Relations *r;
%}

%union{
	char *string;
    //char *option;
	//char[2] *optionArgs;
	//int optionNumber = 0;

}
%token OPT CONCEITO RELATION TERMO
%type <string> OPT RELATION args CONCEITO termos TERMO conceitos relations thesaurus options

%%

thesaurus: options conceitos											{g_hash_table_foreach(conceitos,printCon,NULL);}//printf("%s%s\n",$1,$2);}
	;

options: options OPT args 												{addOption($2, rel4Opts), rel4Opts = NULL, printf("%s - %s\n", $1, $2);}
	|																	{ }
	;

args: RELATION args  													{rel4Opts = g_list_append(rel4Opts, $1); asprintf(&$$, "%s%s", $1, $2);}	 
	| RELATION															{rel4Opts = g_list_append(rel4Opts, $1);}
	;


conceitos:  conceitos CONCEITO relations 								{
																		 searchTerms($2,relations);
																		 c = newConceito($2,relations);
		 																 addConceito(c);
																		 relations = NULL;
			 															 asprintf(&$$,"%s%s\n%s\n" , $1 , $2 ,$3);}
	 	 |																{$$ = " ";}
		 ;

relations: RELATION termos 												{ r = newRelation($1,terms);
																		  relations = addRelationTo(r,relations);
																		  terms = NULL;
																		 asprintf(&$$, "%s - %s", $1, $2);}					
		 | relations RELATION termos  									{r = newRelation($2,terms);
																		 relations = addRelationTo(r,relations);
																		 terms = NULL;
			 															 asprintf(&$$, "%s\n%s - %s", $1, $2 , $3);}
		 ;	

termos: TERMO ',' termos												{ c = newConceito($1,NULL); addConceito(c);
																		 terms = addTermsTo($1,terms);
																		 asprintf(&$$, "%s,%s", $1, $3);}
	  | TERMO 															{ c = newConceito($1,NULL); addConceito(c);
		  																 terms = addTermsTo($1,terms);
		  																 $$ = $1;}
	  ;



%%
#include "lex.yy.c"
int main(){
	#if YYDEBUG
        yydebug = 1;
    #endif
	//conceitos -> contem toda a informacao do sistema
	
	init();
   	printf("Iniciar parse\n");
   	yyparse();
   	printf("Fim de parse\n");
   	//createHTML();
   	//createDOT();


	printf("\n\n\n");
	g_hash_table_foreach(conceitos,printCon,NULL);

   	return 0;
}