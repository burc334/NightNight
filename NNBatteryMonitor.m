#import "NNBatteryMonitor.h"
#import "NNConstants.h"
#import "NNHibernationController.h"
#import "NNSettings.h"

#import <UIKit/UIKit.h>

@interface NNBatteryMonitor ()
@property (nonatomic, readwrite) NSInteger currentLevel;
@property (nonatomic, readwrite, getter=isCharging) BOOL charging;
@property (nonatomic) BOOL started;
@property (nonatomic, strong) NSMutableArray<id<NSObject>> *notificationTokens;
@property (nonatomic, strong) dispatch_source_t pollTimer;
@end

static void NNBatteryPreferencesChanged(CFNotificationCenterRef center,
                                        void *observer,
                                        CFStringRef name,
                                        const void *object,
                                        CFDictionaryRef userInfo) {
    NNBatteryMonitor *monitor = (__bridge NNBatteryMonitor *)observer;
    dispatch_async(dispatch_get_main_queue(), ^{
        [monitor evaluateNow];
    });
}

@implementation NNBatteryMonitor

+ (instancetype)sharedInstance {
    static NNBatteryMonitor *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[NNBatteryMonitor alloc] init];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _armed = YES;
        _notificationTokens = [NSMutableArray array];
    }
    return self;
}

- (void)start {
    if (self.started) {
        return;
    }
    self.started = YES;

    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    __weak typeof(self) weakSelf = self;

    id levelToken = [center addObserverForName:UIDeviceBatteryLevelDidChangeNotification
                                        object:nil
                                         queue:[NSOperationQueue mainQueue]
                                    usingBlock:^(__unused NSNotification *notification) {
        [weakSelf evaluateNow];
    }];
    [self.notificationTokens addObject:levelToken];

    id stateToken = [center addObserverForName:UIDeviceBatteryStateDidChangeNotification
                                        object:nil
                                         queue:[NSOperationQueue mainQueue]
                                    usingBlock:^(__unused NSNotification *notification) {
        [weakSelf evaluateNow];
    }];
    [self.notificationTokens addObject:stateToken];

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    (__bridge const void *)self,
                                    NNBatteryPreferencesChanged,
                                    (__bridge CFStringRef)NNPreferencesChangedNotification,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);

    self.pollTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    if (self.pollTimer) {
        uint64_t interval = (uint64_t)(NNBatteryPollInterval * NSEC_PER_SEC);
        uint64_t leeway = (uint64_t)(5.0 * NSEC_PER_SEC);
        dispatch_source_set_timer(self.pollTimer,
                                  dispatch_time(DISPATCH_TIME_NOW, (int64_t)interval),
                                  interval,
                                  leeway);
        dispatch_source_set_event_handler(self.pollTimer, ^{
            [weakSelf evaluateNow];
        });
        dispatch_resume(self.pollTimer);
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NNStartupDelay * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        if (!weakSelf.started) {
            return;
        }
        [weakSelf evaluateNow];
    });
}

- (void)stop {
    if (!self.started) {
        return;
    }
    self.started = NO;

    for (id token in self.notificationTokens) {
        [[NSNotificationCenter defaultCenter] removeObserver:token];
    }
    [self.notificationTokens removeAllObjects];

    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                       (__bridge const void *)self,
                                       (__bridge CFStringRef)NNPreferencesChangedNotification,
                                       NULL);

    if (self.pollTimer) {
        dispatch_source_cancel(self.pollTimer);
        self.pollTimer = nil;
    }
}

- (NSInteger)currentLevel {
    UIDevice *device = [UIDevice currentDevice];
    if (!device.batteryMonitoringEnabled) {
        device.batteryMonitoringEnabled = YES;
    }
    double level = device.batteryLevel;
    if (level < 0.0) {
        return -1;
    }
    return lround(level * 100.0);
}

- (BOOL)isCharging {
    UIDeviceBatteryState state = [UIDevice currentDevice].batteryState;
    return state == UIDeviceBatteryStateCharging || state == UIDeviceBatteryStateFull;
}

- (void)evaluateNow {
    if (!self.started) {
        return;
    }

    NSInteger level = self.currentLevel;
    BOOL charging = self.isCharging;
    if (level < 0) {
        return;
    }

    NNHibernationController *controller = [NNHibernationController sharedInstance];

    if (controller.isSessionActive) {
        if ([controller evaluateChargerWake:charging]) {
            return;
        }
        [controller evaluateWakeAtLevel:level charging:charging];
        return;
    }

    if (controller.state != NNHibernationStateAwake) {
        return;
    }

    if (![NNSettings enabled] || ![NNSettings autoHibernate]) {
        return;
    }

    if (charging && ![NNSettings allowCharging]) {
        return;
    }

    NSInteger sleepLevel = [NNSettings sleepLevel];
    if (!self.armed) {
        if (level > sleepLevel + NNSleepHysteresis) {
            self.armed = YES;
        } else {
            return;
        }
    }

    if (level <= sleepLevel) {
        [controller hibernateForReason:NNHibernationReasonAutomatic];
    }
}

- (void)dealloc {
    [self stop];
}

@end
