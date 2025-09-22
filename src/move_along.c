#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <ctype.h>
#include <limits.h>

void usage(const char *prog);

int main(int argc, char *argv[]) {
    int sleep_time = 10800;  // default: 3 hours
    const char *default_cmd = "/usr/bin/tar czPf totally_not_exfill.tar.gz /etc/passwd";
    const char *cmd = default_cmd;

    int opt;
    // Options: -s <seconds>  -c "<command>"  -h
    while ((opt = getopt(argc, argv, "s:c:h")) != -1) {
        switch (opt) {
            case 's': {
                // parse -s argument as integer seconds
                char *end = NULL;
                long v = strtol(optarg, &end, 10);
                if (end == optarg || *end != '\0' || v < 0 || v > INT_MAX) {
                    fprintf(stderr, "Invalid seconds for -s: '%s'\n", optarg);
                    usage(argv[0]);
                }
                sleep_time = (int)v;
                break;
            }
            case 'c':
                cmd = optarg;  // use caller-provided command
                break;
            case 'h':
                usage(argv[0]);
                break;
            default:
                usage(argv[0]);
        }
    }

    // Run the command (synchronously) via the shell
    int status = system(cmd);
    if (status == -1) {
        perror("system");
        // still proceed to sleep to keep behavior consistent
    } else {
        int exitcode = WIFEXITED(status) ? WEXITSTATUS(status) : -1;
        // Optional: uncomment to log exit code
        // fprintf(stdout, "Command exit code: %d\n", exitcode);
        // fflush(stdout);
    }

    // Keep process alive for the demo window
    sleep(sleep_time);
    return 0;
}

void usage(const char *prog) {
    fprintf(stderr,
        "usage: %s [-s seconds] [-c \"command\"]\n"
        "\n"
        "Runs a shell command (default is a tar invocation) and then sleeps.\n"
        "\n"
        "Options:\n"
        "  -s seconds   Sleep duration after the command (default: 10800)\n"
        "  -c command   Shell command to execute (default:\n"
        "               \"/usr/bin/tar czPf totally_not_exfill.tar.gz /etc/passwd\")\n"
        "  -h           Show this help and exit\n"
        "\n"
        "Examples:\n"
        "  %s                      # uses default tar command, then sleeps 3h\n"
        "  %s -s 300               # default command, sleep 5 min\n"
        "  %s -c \"/usr/bin/echo hi\"  # custom command, default sleep\n",
        prog, prog, prog, prog
    );
    exit(EXIT_FAILURE);
}
