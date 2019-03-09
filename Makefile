# the compiler: gcc for C program, define as g++ for C++
CC = gcc

# compiler flags:
  #  -g    adds debugging information to the executable file
  #  -Wall turns on most, but not all, compiler warnings
CFLAGS  = -g -Wall


# To create the executable file count we need the object files
program: normalizar.c Noticia.o
		$(CC) $(CFLAGS) -o program normalizar.c Noticia.o

Noticia.o: Noticia.c Noticia.h
		$(CC) -c Noticia.c

normalizar.c: normalizar.flex
		flex -o normalizar.c normalizar.flex


clean: 
	$(RM) *.o *~
	$(RM) normalizar.c
	$(RM) program
