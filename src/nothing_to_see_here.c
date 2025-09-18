#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <string.h>

void usage(void);

int main(int argc, char *argv[]) {

  int opt;
  int sleep_time;
  //str file_name;
      
  // put ':' in the starting of the string so that program can 
  // distinguish between '?' and ':' 
  while((opt = getopt(argc, argv, ":f:s:lrx")) != -1) 
  { 
    switch(opt) 
    { 
      case 's': 
        printf("sleep: %c\n", optarg);
        // Convert the sleep argument to an integer for use in sleep()
        //char *p;
        //long conv = strtol(optarg, &p, 10);
        //sleep_time = conv;	
        break; 
      case 'f': 
        printf("filename: %s\n", optarg); 
	//file_name = optarg;
        break; 
      case ':': 
        printf("option needs a value\n"); 
        break; 
      case '?': 
        printf("unknown option: %c\n", optopt);
        break; 
    } 
  }
/*
  if( argc == 2 ) {
    // Convert the sleep argument to an integer for use in sleep()
    char *p;
    long conv = strtol(argv[1], &p, 10);
    int sleep_time = conv;
  }
  else if( argc > 2 ) {
    fprintf(stdout, "Too many arguments\n");
    fflush(stdout);
    usage();
  }
  pid_t p = fork();
  if (p == 0) {
    char *args[]={"/dev/shm/move_along",sleep_time, NULL};
    execvp(args[0], args);
  }
  else if (p < 0) {
    fprintf(stdout, "Some error occured\n");
    fflush(stdout);
    _exit(-1);
  }
  else if (p > 0) {
    fprintf(stdout, "Still in Parent\n");
    fflush(stdout);
    _exit(3);
  }*/
}
