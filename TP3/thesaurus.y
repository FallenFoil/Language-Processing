%code{
 #include <stdio.h>
 int yyerror(char *s){ fprintf(stderr, "Erro:%s\n", s);}
 int yylex();
 int n = 0;
}

%union{
	char *string;
    //char *option;
	//char[2] *optionArgs;
	//int optionNumber = 0;

}
%token OPT ARG
%type <string> OPT ARG args

%%

thesaurus: options
	;

options: options OPT args  {printf("%s - %s\n", $2, $3);}
	| OPT args {printf("%s - %s", $1, $2);}
	;

args: ARG args  {$$ = $1;}	 
	| ARG 		{$$ = $1;}
	;


%%
#include "lex.yy.c"
int main(){
   printf("Iniciar parse\n");
   yyparse();
   printf("Fim de parse\n");
   return 0;
}
