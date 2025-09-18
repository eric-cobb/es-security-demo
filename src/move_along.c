#include <stdlib.h>
#include <stdio.h>
#include <signal.h>
#include <unistd.h>

void usage(void);

int main( int argc, char *argv[] ) {
  // Default sleep time
  int sleep_time = 10800;

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

  int status = system("/usr/bin/tar czPf totally_not_exfill.tar.gz /etc/passwd");
  int exitcode = status / 256;
  // Busy wait, keep process running for 5 hours.
  // This should be enough time to run the demo script
  // and do the demo before the process exits 
  sleep(sleep_time);
  exit(0);
}

void usage(void) {
  fprintf(stderr, "usage: move_along [sleep_time_in_seconds (Default: 10800)]\n");
  exit(EXIT_FAILURE);
}
