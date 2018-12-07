#include <time.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
	int d = 1;
	if(argc > 1) {
		d = atoi(argv[1]);
		if(!d) d = 1;
	}
	do{
		time_t t = time(NULL);
		struct tm tm = *localtime(&t);
		printf("%d-%.2d-%.2d %.2d:%.2d:%.2d\n",
				tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday,
				tm.tm_hour, tm.tm_min, tm.tm_sec);
	}while(!sleep(d));
}

