CC = gcc
ASMFLAGS = -Wall -g
CFLAGS = -Wall -g


OBJ_C = string_manipulation.o
OBJ_ASM = my_fun.o
EXEC = string_manipulation.out

all: $(EXEC)

$(EXEC): $(OBJ_C) $(OBJ_ASM)
        $(CC) $(OBJ_C) $(OBJ_ASM) -o $(EXEC)

$(OBJ_C): string_manipulation.c
        $(CC) $(CFLAGS) -c string_manipulation.c -o $(OBJ_C)

$(OBJ_ASM): my_fun.s
        $(CC) $(ASMFLAGS) -c my_fun.s -o $(OBJ_ASM)

clean:
        rm -f $(OBJ_C) $(OBJ_ASM) $(EXEC)