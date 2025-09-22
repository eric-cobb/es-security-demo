#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static void usage(const char *prog, const char *default_prog) {
    printf(
        "Usage:\n"
        "  %s [program-to-run] [args...]\n"
        "  %s [flags-for-default]\n"
        "\n"
        "Behavior:\n"
        "  • If the first argument starts with '-', arguments are passed to the default program:\n"
        "      %s -s 60 -c \"/bin/echo hi\"  -> runs %s with those flags\n"
        "  • If the first argument does not start with '-', it is treated as the program to run:\n"
        "      %s /usr/bin/echo hello        -> runs /usr/bin/echo hello\n"
        "  • If no arguments are given, runs the default program with no args.\n"
        "\n"
        "Options:\n"
        "  -h, --help   Show this help (for the launcher)\n",
        prog, prog, prog, default_prog, prog
    );
}

int main(int argc, char *argv[]) {
    const char *default_prog = "/dev/shm/move_along";

    // Launcher's own help
    if (argc > 1 && (strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "--help") == 0)) {
        usage(argv[0], default_prog);
        return 0;
    }

    pid_t pid = fork();
    if (pid < 0) {
        perror("fork");
        return 1;
    }

    if (pid == 0) {
        // Child
        if (argc < 2) {
            // No args -> run default with no args
            char *child_argv[] = { (char *)default_prog, NULL };
            execvp(child_argv[0], child_argv);
            perror("execvp");
            _exit(127);
        }

        if (argv[1][0] == '-') {
            // Treat all given args as flags for the default program.
            // Build: [default_prog, argv[1], argv[2], ..., NULL]
            int child_argc = argc;              // default_prog + (argc-1) flags
            char **child_argv = calloc((size_t)child_argc + 1, sizeof(char *));
            if (!child_argv) {
                perror("calloc");
                _exit(127);
            }
            child_argv[0] = (char *)default_prog;
            for (int i = 1; i < argc; i++) child_argv[i] = argv[i];
            child_argv[child_argc] = NULL;

            execvp(child_argv[0], child_argv);
            perror("execvp");
            _exit(127);
        } else {
            // argv[1] is the program; forward it and any following args directly
            execvp(argv[1], &argv[1]);
            perror("execvp");
            _exit(127);
        }
    }

    // Parent exits immediately
    return 0;
}