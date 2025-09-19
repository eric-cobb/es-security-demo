#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <string.h>

void usage(void);

int main(int argc, char *argv[]) {

  pid_t p = fork();
  if (p == 0) {
    char *args[]={"/dev/shm/move_along", NULL};
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
  }
}
