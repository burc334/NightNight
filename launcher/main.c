#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#ifndef PATH_MAX
#define PATH_MAX 4096
#endif

static const char *kReadyPath = "/var/mobile/Library/Preferences/com.burc334.nightnight.sleepd.ready";
static const char *kRootDirectory = "/var/containers/Bundle/Application";
static const char *kRunnerRelative = "Library/MobileSubstrate/DynamicLibraries/NightNightRunner";
static const char *kDylibRelative = "Library/MobileSubstrate/DynamicLibraries/NightNight.dylib";
static const char *kRootlessRunner = "/var/jb/Library/MobileSubstrate/DynamicLibraries/NightNightRunner";
static const char *kRootlessDylib = "/var/jb/Library/MobileSubstrate/DynamicLibraries/NightNight.dylib";

static volatile pid_t childPID = -1;

static void write_ready(void) {
    int fd = open(kReadyPath, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd < 0) {
        return;
    }
    char buffer[32];
    int length = snprintf(buffer, sizeof(buffer), "pid=%d\n", (int)getpid());
    if (length > 0) {
        (void)write(fd, buffer, (size_t)length);
    }
    close(fd);
}

static void ready_signal(int signalNumber) {
    (void)signalNumber;
    write_ready();
}

static void shutdown_signal(int signalNumber) {
    (void)signalNumber;
    if (childPID > 0) {
        kill(childPID, SIGTERM);
    }
    unlink(kReadyPath);
    _exit(0);
}

static int file_exists(const char *path, int executable) {
    if (executable) {
        return access(path, X_OK) == 0;
    }
    return access(path, R_OK) == 0;
}

static int find_runner(char *result, size_t resultSize) {
    DIR *directory = opendir(kRootDirectory);
    if (!directory) {
        return 0;
    }

    int count = 0;
    char candidate[PATH_MAX];
    candidate[0] = '\0';

    struct dirent *entry = NULL;
    while ((entry = readdir(directory)) != NULL) {
        if (strncmp(entry->d_name, ".jbroot-", 8) != 0) {
            continue;
        }

        char root[PATH_MAX];
        char runner[PATH_MAX];
        char dylib[PATH_MAX];
        if (snprintf(root, sizeof(root), "%s/%s", kRootDirectory, entry->d_name) >= (int)sizeof(root)) {
            continue;
        }
        if (snprintf(runner, sizeof(runner), "%s/%s", root, kRunnerRelative) >= (int)sizeof(runner)) {
            continue;
        }
        if (snprintf(dylib, sizeof(dylib), "%s/%s", root, kDylibRelative) >= (int)sizeof(dylib)) {
            continue;
        }

        if (file_exists(runner, 1) && file_exists(dylib, 0)) {
            count++;
            snprintf(candidate, sizeof(candidate), "%s", runner);
        }
    }
    closedir(directory);

    if (count == 1) {
        snprintf(result, resultSize, "%s", candidate);
        return 1;
    }

    if (count == 0 && file_exists(kRootlessRunner, 1) && file_exists(kRootlessDylib, 0)) {
        snprintf(result, resultSize, "%s", kRootlessRunner);
        return 1;
    }

    return 0;
}

static int start_child(const char *runner) {
    pid_t pid = fork();
    if (pid < 0) {
        return -1;
    }
    if (pid == 0) {
        setenv("NIGHTNIGHT_READY_SIGNAL", "1", 1);
        execl(runner, runner, "--daemon", (char *)NULL);
        _exit(127);
    }
    return (int)pid;
}

int main(void) {
    signal(SIGUSR1, ready_signal);
    signal(SIGTERM, shutdown_signal);
    signal(SIGINT, shutdown_signal);
    signal(SIGHUP, shutdown_signal);
    unlink(kReadyPath);

    for (;;) {
        char runner[PATH_MAX];
        if (!find_runner(runner, sizeof(runner))) {
            unlink(kReadyPath);
            sleep(60);
            continue;
        }

        int pid = start_child(runner);
        if (pid < 0) {
            sleep(60);
            continue;
        }

        childPID = (pid_t)pid;
        int status = 0;
        while (waitpid(childPID, &status, 0) < 0) {
            if (errno != EINTR) {
                break;
            }
        }
        childPID = -1;
        unlink(kReadyPath);
        sleep(30);
    }
}
