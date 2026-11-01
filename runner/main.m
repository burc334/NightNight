#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>
#import <IOKit/pwr_mgt/IOPMLib.h>
#import <notify.h>
#import <signal.h>
#import <stdlib.h>
#import <string.h>
#import <unistd.h>

static NSString *const NNSleepDaemonNotification = @"com.burc334.nightnight.sleep";

static int performSleep(void) {
    io_service_t rootDomain = IORegistryEntryFromPath(kIOMasterPortDefault,
                                                       "IOPower:/IOPowerConnection/IOPMrootDomain");
    if (rootDomain != 0) {
        IORegistryEntrySetCFProperty(rootDomain,
                                     CFSTR("System Boot Complete"),
                                     kCFBooleanTrue);
        IOObjectRelease(rootDomain);
    }

    io_connect_t connection = IOPMFindPowerManagement(kIOMasterPortDefault);
    if (connection == 0) {
        return 2;
    }

    IOReturn result = IOPMSleepSystem(connection);
    IOServiceClose(connection);
    return result == kIOReturnSuccess ? 0 : 3;
}

static int runDaemon(void) {
    setgid(0);
    setuid(0);

    __block BOOL sleeping = NO;
    int token = 0;
    uint32_t status = notify_register_dispatch(NNSleepDaemonNotification.UTF8String,
                                                &token,
                                                dispatch_get_main_queue(), ^(int notifyToken) {
        (void)notifyToken;
        if (sleeping) {
            return;
        }
        sleeping = YES;
        performSleep();
        sleeping = NO;
    });

    if (status != NOTIFY_STATUS_OK) {
        return 4;
    }

    if (getenv("NIGHTNIGHT_READY_SIGNAL") != NULL && getppid() > 1) {
        kill(getppid(), SIGUSR1);
    }

    dispatch_main();
    return 0;
}

int main(int argc, char *argv[]) {
    if (argc > 1 && strcmp(argv[1], "--daemon") == 0) {
        return runDaemon();
    }
    return 2;
}
