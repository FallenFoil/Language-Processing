%{
#define YYDEBUG 0
 #include <stdio.h>
 #include <glib.h>
 #include "structs.c"
 int yyerror(char *s){ fprintf(stderr, "Erro:%s\n", s); return 0;}
 int yylex();
 
 GList *terms = NULL;
 GList *relations = NULL;
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
%type <string> OPT RELATION args CONCEITO termos TERMO conceitos relations thesaurus options

%%

thesaurus: options conceitos											{g_hash_table_foreach(conceitos,printCon,NULL);}//printf("%s%s\n",$1,$2);}
	;

options: OPT args '\n' options 												{printf("%s - %s\n", $1, $2);}
	| OPT args 															{printf("%s - %s\n", $1, $2);}
	|																	{ }
	;

args: RELATION args  													{asprintf(&$$, "%s%s", $1, $2);}	 
	| RELATION															{$$ = $1;}
	;


conceitos: CONCEITO relations											{ c = newConceito($1,relations);
																		 addConceito(c);
																		 relations = NULL;
																		 asprintf(&$$,"%s\n%s\n", $1, $2);}
		 | CONCEITO relations "\n\n" conceitos								{ c = newConceito($2,relations);
		 																 addConceito(c);
																		 relations = NULL;
			 															 asprintf(&$$,"%s%s\n%s\n" , $1 , $2 ,$4);}
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

termos: TERMO ',' termos												{ terms = addTermsTo($1,terms);
																		 asprintf(&$$, "%s,%s", $1, $3);}
	  | TERMO 															{ terms = addTermsTo($1,terms);
		  																 $$ = $1;}
	  ;



%%
#include "lex.yy.c"
int main(){
	#if YYDEBUG
        yydebug = 1;
    #endif
	
	conceitos = g_hash_table_new(g_str_hash, g_str_equal);
	
	//conceitos -> contem toda a informacao do sistema
	//para confirmar -> g_hash_table_foreach(conceitos,printConceito,NULL);
	initConceitos();
   	printf("Iniciar parse\n");
   	yyparse();
   	printf("Fim de parse\n");
   	createHTML();
   	return 0;
}