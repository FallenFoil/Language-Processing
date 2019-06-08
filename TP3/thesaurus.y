%{
#define YYDEBUG 0
%}
%code requires{
 #include <stdio.h>
 int yyerror(char *s){ fprintf(stderr, "Erro:%s\n", s); return 0;}
 int yylex();
}
%union{
	char *string;
    //char *option;
	//char[2] *optionArgs;
	//int optionNumber = 0;

}
%token OPT CONCEITO RELATION TERMO
%type <string> OPT RELATION args CONCEITO termos TERMO conceitos relations

%%

thesaurus: options conceitos
	;

options: OPT args options 										{printf("%s - %s\n", $1, $2);}
	| OPT args 													{printf("%s - %s\n", $1, $2);}
	|															{ }
	;

args: RELATION args  											{asprintf(&$$, "%s%s", $1, $2);}	 
	| RELATION													{$$ = $1;}
	;

conceitos: CONCEITO relations conceitos 						{printf("%s\n\n%s\n", $1, $2);}
		 | CONCEITO relations 									{printf("%s\n%s\n", $1 , $2);}
	 	 |														{$$ = " ";}
		 ;

relations: RELATION termos relations							{asprintf(&$$, "%s - %s\n", $1, $2);}					
		 | 														{$$ = " ";}
		 ;	

termos: TERMO ',' termos										{asprintf(&$$, "%s,%s", $1, $3);}
	  | TERMO 													{ $$ = $1;}
	  ;



%%
#include "lex.yy.c"
#include "structs.c"
int main(){
	#if YYDEBUG
        yydebug = 1;
    #endif
	initConceitos();
   	printf("Iniciar parse\n");
   	yyparse();
   	printf("Fim de parse\n");
   	createHTML();
   	return 0;
}
