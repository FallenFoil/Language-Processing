%{
#define YYDEBUG 1
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
%token OPT CONCEITO ARG TERMO QUEBRA_LINHA
%type <string> OPT ARG args CONCEITO termos TERMO conceitos relations QUEBRA_LINHA

%%

thesaurus: options conceitos
	;

options: OPT args '\n' options 									{printf("%s - %s\n", $1, $2);}
	| OPT args 													{printf("%s - %s\n", $1, $2);}
	|															{ }
	;

args: ARG args  												{asprintf(&$$, "%s%s", $1, $2);}	 
	| ARG														{$$ = $1;}
	;

conceitos: conceitos QUEBRA_LINHA CONCEITO '\n' relations 		{printf("%s\n\n%s\n%s\n", $1, $3 , $5);}
		 | CONCEITO '\n' relations 								{printf("%s\n%s\n", $1 , $3);}
	 	 |														{$$ = " ";}
		 ;

relations: ARG termos '\n' relations							{asprintf(&$$, "%s - %s\n", $1, $2);}					
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
   	return 0;
}
