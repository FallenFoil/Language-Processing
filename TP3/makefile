# compiler flags:
  #  -g    adds debugging information to the executable file
  #  -Wall turns on most, but not all, compiler warnings
CFLAGS  = -g -Wall `pkg-config --cflags glib-2.0`
LIBS = `pkg-config --libs glib-2.0`


thesaurus: thesaurus.fl thesaurus.y
	flex thesaurus.fl
	yacc -v thesaurus.y 
	cc $(CFLAGS) -o thesaurus_2788 y.tab.c -D _GNU_SOURCE -D DEBUG_FL -ly -lm $(LIBS)
	mkdir html
	mkdir html/conceitos
	mkdir html/relacoes

clean:
	rm -f y.tab.c lex.yy.c thesaurus_2788
	rm -rf html
