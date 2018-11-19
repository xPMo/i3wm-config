CC = gcc

i3blocks-time: src/time_loop.c
	$(CC) -o LIB/i3blocks/_time_loop src/time_loop.c -Ofast
