
#include <pty.h>
#include <sys/wait.h>

#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>

pid_t spawnRedirected(int slave, char* command, char* arg)
{
    pid_t pid = fork();
    if (pid == 0) {
        setsid();
        ioctl(slave, TIOCSCTTY, 0);
        if (slave > 2)
	    close(slave);
	char* argv[] = { command, arg, NULL };
        execvp(argv[0], argv);
        exit(1);
    }
    return pid;
}


