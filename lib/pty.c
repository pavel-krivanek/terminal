
#include <pty.h>
#include <sys/wait.h>

#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>

int setWindowSize(int fd, int cols, int rows)
{/*
#if defined(TIOCSWINSZ)
  struct winsize sz;
  sz.ws_col= cols;
  sz.ws_row= rows;
  sz.ws_xpixel= sz.ws_ypixel= 0;
  if (ioctl(fd, TIOCSWINSZ, &sz) == -1)
    return 1;
#endif
  return 0;
  */
}

int hasChar(int* aMaster)
{
    fd_set rfds;
    struct timeval tv;
    tv.tv_sec = 0;
    tv.tv_usec = 0;
    char buf[1];
    FD_ZERO(&rfds);
    FD_SET(*aMaster, &rfds);
    return select(*aMaster + 1, &rfds, NULL, NULL, &tv);
}

int readAndPrint(int* aMaster)
{
    ssize_t size;
    char buf[4097];
    size = read(*aMaster, buf, 4096);
    buf[size] = '\0';
    printf("%d\n", size);
    printf("%s", buf);

    return (int)size;
}

int readTo(int* aMaster, char* buffer, int maxLength)
{
    ssize_t size;
    size = read(*aMaster, buffer, maxLength);

    return (int)size;
}

int writeTo(int* aMaster, char* buffer, int length)
{
    ssize_t size;
    size = write(*aMaster, buffer, length);

    return (int)size;
}

static int login_tty(int pts)
{
#if defined(HAVE_STROPTS_H)
    /* push a terminal onto stream head */
    if (ioctl(pts, I_PUSH, "ptem") == -1)
        return -1;
    if (ioctl(pts, I_PUSH, "ldterm") == -1)
        return -1;
#endif
    setsid();
#if defined(TIOCSCTTY)
    ioctl(pts, TIOCSCTTY, 0);
#endif
 //   dup2(pts, 0);
 //   dup2(pts, 1);
 //   dup2(pts, 2);
    if (pts > 2)
        close(pts);
    return 0;
}

int openMasterSlave(int* master, int* slave)
{
    openpty(master, slave, NULL, NULL, NULL);

    int _stdout = dup(STDOUT_FILENO);
    dup2(*slave, STDOUT_FILENO);
    int _stdin = dup(STDIN_FILENO);
    dup2(*slave, STDIN_FILENO);
    int _stderr = dup(STDERR_FILENO);
    dup2(*slave, STDERR_FILENO);

    pid_t pid = fork();
    if (pid == 0) {
        login_tty(*slave);
        //char *argv[] = {"cat", "hello.txt", NULL};
        //char* argv[] = { "/bin/bash", "run.sh", NULL };
	char* argv[] = { "/bin/bash", "-i", NULL };
        execvp(argv[0], argv);
        exit(1);
    }

    // Child process terminated; we flush the output and restore stdout.
    fsync(STDIN_FILENO);
    dup2(_stdin, STDIN_FILENO);
    fsync(STDOUT_FILENO);
    dup2(_stdout, STDOUT_FILENO);
    fsync(STDERR_FILENO);
    dup2(_stderr, STDERR_FILENO);
    return 0;
}

int closeMasterSlave(int* master, int* slave)
{
    close(*master);
    close(*slave);
    return 0;
}

int openpty_demo2(int arg)
{

    int master;
    int slave;

    openpty(&master, &slave, NULL, NULL, NULL);

    int _stdout = dup(STDOUT_FILENO);
    dup2(slave, STDOUT_FILENO);

    pid_t pid = fork();
    if (pid == 0) {
        //char *argv[] = {"cat", "hello.txt", NULL};
        char* argv[] = { "/bin/bash", "run.sh", NULL };
        execvp(argv[0], argv);
    }

    // Child process terminated; we flush the output and restore stdout.
    fsync(STDOUT_FILENO);
    dup2(_stdout, STDOUT_FILENO);

    printf("PID: %d\n", pid);

    int result = -1;
    while (result == -1) {
        result = hasChar(&master);
        printf("%d\n", result);
    }
    readAndPrint(&master);

    // Close both ends of the pty.
    close(master);
    close(slave);

    return arg + 7;
}

