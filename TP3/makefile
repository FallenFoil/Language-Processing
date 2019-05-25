notas: thesaurus.fl thesaurus.y
	flex thesaurus.fl
	yacc thesaurus.y
	cc -o thesaurus_2788 y.tab.c -ly -lm

clean:
	rm -f y.tab.c lex.yy.c thesaurus_2788
