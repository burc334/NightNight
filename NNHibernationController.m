#import "NNHibernationController.h"
#import "NNBatteryMonitor.h"
#import "NNConstants.h"
#import "NNLog.h"
#import "NNPrivateAPI.h"
#import "NNSettings.h"
#import "NNStateStore.h"

#import <MediaRemote/MediaRemote.h>
#import <dlfcn.h>
#import <notify.h>
#import <objc/message.h>
#import <UIKit/UIKit.h>
#import <unistd.h>

static void NNManualHibernateCallback(CFNotificationCenterRef center,
                                      void *observer,
                                      CFStringRef name,
                                      const void *object,
                                      CFDictionaryRef userInfo) {
    (void)center;
    (void)name;
    (void)object;
    (void)userInfo;
    NNHibernationController *controller = (__bridge NNHibernationController *)observer;
    dispatch_async(dispatch_get_main_queue(), ^{
        [controller hibernateForReason:NNHibernationReasonManual];
    });
}

@interface NNHibernationController ()
@property (nonatomic, readwrite) NNHibernationState state;
@property (nonatomic, readwrite, getter=isSessionActive) BOOL sessionActive;
@property (nonatomic) BOOL started;
@property (nonatomic) BOOL wakeArmed;
@property (nonatomic) BOOL chargerConnectedAtHibernate;
@property (nonatomic) BOOL changedAirplane;
@property (nonatomic) BOOL changedWiFi;
@property (nonatomic) BOOL changedBluetooth;
@property (nonatomic) BOOL changedLowPower;
@property (nonatomic) BOOL mutedRinger;
@property (nonatomic) float cachedRingtoneVolume;
@property (nonatomic) BOOL lockedByUs;
@property (nonatomic) BOOL changedProximity;
@property (nonatomic) BOOL cachedAirplane;
@property (nonatomic) BOOL cachedWiFi;
@property (nonatomic) BOOL cachedBluetooth;
@property (nonatomic) BOOL wifiStateKnown;
@property (nonatomic) BOOL bluetoothStateKnown;
@property (nonatomic) BOOL cachedLowPower;
@property (nonatomic) BOOL cachedLocked;
@property (nonatomic) BOOL cachedProximity;
@end

@implementation NNHibernationController

+ (instancetype)sharedInstance {
    static NNHibernationController *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[NNHibernationController alloc] init];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _state = NNHibernationStateAwake;
    }
    return self;
}

- (void)start {
    if (self.started) {
        return;
    }
    self.started = YES;
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    (__bridge const void *)self,
                                    NNManualHibernateCallback,
                                    (__bridge CFStringRef)NNManualHibernateNotification,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    [self recoverIfNeeded];
}

- (void)recoverIfNeeded {
    NSDictionary *snapshot = [NNStateStore loadSnapshot];
    if (!snapshot) {
        return;
    }

    if ([snapshot[@"MutedRinger"] boolValue]) {
        self.mutedRinger = YES;
        self.cachedRingtoneVolume = [snapshot[@"CachedRingtoneVolume"] floatValue];
        [self restoreRinger];
    }
    if ([snapshot[@"ChangedWiFi"] boolValue]) {
        [self setWiFiEnabled:[snapshot[@"CachedWiFi"] boolValue]];
    }
    if ([snapshot[@"ChangedBluetooth"] boolValue]) {
        [self setBluetoothEnabled:[snapshot[@"CachedBluetooth"] boolValue]];
    }
    if ([snapshot[@"ChangedAirplane"] boolValue]) {
        [self setAirplaneMode:[snapshot[@"CachedAirplane"] boolValue]];
    }
    if ([snapshot[@"ChangedLowPower"] boolValue]) {
        [self setLowPowerMode:[snapshot[@"CachedLowPower"] boolValue]];
    }
    if ([snapshot[@"LockedByUs"] boolValue]) {
        id lock = NNSharedInstance(@"SBLockScreenManager");
        if (NNObjectResponds(lock, @"unlockUIFromSource:withOptions:")) {
            [(SBLockScreenManager *)lock unlockUIFromSource:2 withOptions:nil];
        }
    }
    id backlight = NNSharedInstance(@"SBBacklightController");
    if (NNObjectResponds(backlight, @"turnOnScreenFullyWithBacklightSource:")) {
        [(SBBacklightController *)backlight turnOnScreenFullyWithBacklightSource:0];
    }
    [NNStateStore clearSnapshot];
    self.sessionActive = NO;
    self.state = NNHibernationStateAwake;
    [NNBatteryMonitor sharedInstance].armed = NO;
}

- (void)hibernateForReason:(NNHibernationReason)reason {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hibernateForReason:reason];
        });
        return;
    }

    if (self.sessionActive || self.state != NNHibernationStateAwake) {
        return;
    }
    if (![NNSettings enabled]) {
        return;
    }

    NNBatteryMonitor *battery = [NNBatteryMonitor sharedInstance];
    if (reason == NNHibernationReasonAutomatic &&
        battery.isCharging &&
        ![NNSettings allowCharging]) {
        return;
    }

    self.chargerConnectedAtHibernate = battery.isCharging;
    self.sessionActive = YES;
    self.wakeArmed = (battery.currentLevel < [NNSettings wakeLevel]);
    self.state = NNHibernationStatePreparing;
    [self cacheCurrentState];

    if (![self prepareHibernation]) {
        self.sessionActive = NO;
        [self restoreCachedState];
        [NNStateStore clearSnapshot];
        self.state = NNHibernationStateAwake;
        return;
    }

    [self saveRecoverySnapshot];

    if (![self requestDaemonSleep]) {
        self.sessionActive = NO;
        [self restoreCachedState];
        [NNStateStore clearSnapshot];
        self.state = NNHibernationStateAwake;
        return;
    }

    self.state = NNHibernationStateHibernating;
}

- (BOOL)requestDaemonSleep {
    NSString *readyPath = @"/var/mobile/Library/Preferences/com.burc334.nightnight.sleepd.ready";
    if (![[NSFileManager defaultManager] fileExistsAtPath:readyPath]) {
        NNLogError(@"sleep daemon is not ready");
        return NO;
    }

    uint32_t status = notify_post("com.burc334.nightnight.sleep");
    if (status != NOTIFY_STATUS_OK) {
        NNLogError(@"sleep notification failed: %u", status);
        return NO;
    }
    return YES;
}

- (void)wakeForReason:(NNHibernationReason)reason {
    (void)reason;
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self wakeForReason:reason];
        });
        return;
    }

    if (!self.sessionActive) {
        return;
    }

    self.state = NNHibernationStateWaking;
    self.sessionActive = NO;
    [self restoreCachedState];
    [NNStateStore clearSnapshot];
    self.state = NNHibernationStateAwake;
    [NNBatteryMonitor sharedInstance].armed = NO;
}

- (BOOL)evaluateChargerWake:(BOOL)charging {
    if (!self.sessionActive || ![NNSettings wakeOnCharger]) {
        return NO;
    }
    if (charging && !self.chargerConnectedAtHibernate) {
        [self wakeForReason:NNHibernationReasonCharger];
        return YES;
    }
    if (!charging) {
        self.chargerConnectedAtHibernate = NO;
    }
    return NO;
}

- (void)evaluateWakeAtLevel:(NSInteger)level charging:(BOOL)charging {
    if (!self.sessionActive || [NNSettings wakeOnCharger]) {
        return;
    }
    if (!charging) {
        return;
    }
    if (level < [NNSettings wakeLevel]) {
        self.wakeArmed = YES;
        return;
    }
    if (self.wakeArmed && level >= [NNSettings wakeLevel]) {
        [self wakeForReason:NNHibernationReasonAutoWake];
    }
}

- (void)cacheCurrentState {
    id airplane = NNSharedInstance(@"SBAirplaneModeController");
    if (NNObjectResponds(airplane, @"isInAirplaneMode")) {
        self.cachedAirplane = [(SBAirplaneModeController *)airplane isInAirplaneMode];
    } else {
        self.cachedAirplane = NO;
    }

    BOOL wifiEnabled = NO;
    self.wifiStateKnown = [self getWiFiEnabled:&wifiEnabled];
    if (self.wifiStateKnown) {
        self.cachedWiFi = wifiEnabled;
    }
    BOOL bluetoothEnabled = NO;
    self.bluetoothStateKnown = [self getBluetoothEnabled:&bluetoothEnabled];
    if (self.bluetoothStateKnown) {
        self.cachedBluetooth = bluetoothEnabled;
    }

    self.cachedLowPower = [NSProcessInfo processInfo].isLowPowerModeEnabled;

    id lock = NNSharedInstance(@"SBLockScreenManager");
    if (NNObjectResponds(lock, @"isUILocked")) {
        self.cachedLocked = [(SBLockScreenManager *)lock isUILocked];
    } else {
        self.cachedLocked = YES;
    }

    self.cachedProximity = [UIDevice currentDevice].isProximityMonitoringEnabled;
}

- (BOOL)prepareHibernation {
    id airplane = NNSharedInstance(@"SBAirplaneModeController");
    id backlight = NNSharedInstance(@"SBBacklightController");
    id lock = NNSharedInstance(@"SBLockScreenManager");

    if (!airplane || !backlight || !lock) {
        NNLogError(@"required SpringBoard controllers are unavailable");
        return NO;
    }

    if (!self.cachedLowPower && [self setLowPowerMode:YES]) {
        self.changedLowPower = YES;
    }

    if ([self muteRinger]) {
        self.mutedRinger = YES;
    }

    if (!self.cachedAirplane) {
        if ([self setAirplaneMode:YES]) {
            self.changedAirplane = YES;
        } else {
            NNLogError(@"airplane mode could not be forced on");
        }
    }

    if (self.wifiStateKnown) {
        if ([self setWiFiEnabled:NO]) {
            self.changedWiFi = self.cachedWiFi;
        } else {
            NNLogError(@"wifi could not be disabled");
        }
    } else {
        NNLogError(@"wifi state unavailable");
    }

    if (self.bluetoothStateKnown) {
        if ([self setBluetoothEnabled:NO]) {
            self.changedBluetooth = self.cachedBluetooth;
        } else {
            NNLogError(@"bluetooth could not be disabled");
        }
    } else {
        NNLogError(@"bluetooth state unavailable");
    }

    usleep(1000000);

    if (!self.cachedLocked &&
        NNObjectResponds(lock, @"lockUIFromSource:withOptions:")) {
        [(SBLockScreenManager *)lock lockUIFromSource:2 withOptions:nil];
        self.lockedByUs = YES;
    }

    MRMediaRemoteSendCommand(MRMediaRemoteCommandPause, nil);

    if (NNObjectResponds(backlight, @"_startFadeOutAnimationFromLockSource:")) {
        [(SBBacklightController *)backlight _startFadeOutAnimationFromLockSource:0];
    }

    if (self.cachedProximity) {
        [UIDevice currentDevice].proximityMonitoringEnabled = NO;
        self.changedProximity = YES;
    }

    return YES;
}

- (void)restoreCachedState {
    [self restoreRinger];

    if (self.changedWiFi) {
        [self setWiFiEnabled:self.cachedWiFi];
        self.changedWiFi = NO;
    }
    if (self.changedBluetooth) {
        [self setBluetoothEnabled:self.cachedBluetooth];
        self.changedBluetooth = NO;
    }
    if (self.changedAirplane) {
        [self setAirplaneMode:self.cachedAirplane];
        self.changedAirplane = NO;
    }

    if (self.changedLowPower) {
        [self setLowPowerMode:self.cachedLowPower];
        self.changedLowPower = NO;
    }

    if (self.lockedByUs) {
        id lock = NNSharedInstance(@"SBLockScreenManager");
        if (NNObjectResponds(lock, @"unlockUIFromSource:withOptions:")) {
            [(SBLockScreenManager *)lock unlockUIFromSource:2 withOptions:nil];
        }
        self.lockedByUs = NO;
    }

    id backlight = NNSharedInstance(@"SBBacklightController");
    if (NNObjectResponds(backlight, @"turnOnScreenFullyWithBacklightSource:")) {
        [(SBBacklightController *)backlight turnOnScreenFullyWithBacklightSource:0];
    }

    if (self.changedProximity) {
        [UIDevice currentDevice].proximityMonitoringEnabled = self.cachedProximity;
        self.changedProximity = NO;
    }
}

- (nullable id)avSystemController {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dlopen("/System/Library/PrivateFrameworks/Celestial.framework/Celestial", RTLD_LAZY);
    });
    Class cls = NNClass(@"AVSystemController");
    if (!cls || ![cls respondsToSelector:@selector(sharedAVSystemController)]) {
        return nil;
    }
    id (*shared)(id, SEL) = (id (*)(id, SEL))objc_msgSend;
    return shared((id)cls, @selector(sharedAVSystemController));
}

- (BOOL)getRingtoneVolume:(float *)volume {
    id controller = [self avSystemController];
    SEL selector = @selector(getVolume:forCategory:);
    if (![controller respondsToSelector:selector]) {
        return NO;
    }
    BOOL (*getVolume)(id, SEL, float *, NSString *) =
        (BOOL (*)(id, SEL, float *, NSString *))objc_msgSend;
    return getVolume(controller, selector, volume, @"Ringtone");
}

- (BOOL)setRingtoneVolume:(float)volume {
    id controller = [self avSystemController];
    SEL selector = @selector(setVolumeTo:forCategory:);
    if (![controller respondsToSelector:selector]) {
        return NO;
    }
    BOOL (*setVolume)(id, SEL, float, NSString *) =
        (BOOL (*)(id, SEL, float, NSString *))objc_msgSend;
    return setVolume(controller, selector, volume, @"Ringtone");
}

- (BOOL)muteRinger {
    float volume = 1.0f;
    if (![self getRingtoneVolume:&volume]) {
        return NO;
    }
    self.cachedRingtoneVolume = volume;
    return [self setRingtoneVolume:0.0f];
}

- (void)restoreRinger {
    if (!self.mutedRinger) {
        return;
    }
    [self setRingtoneVolume:self.cachedRingtoneVolume];
    self.mutedRinger = NO;
}

- (nullable id)wifiController {
    Class cls = NNClass(@"SBWiFiManager");
    if (!cls || ![cls respondsToSelector:@selector(sharedInstance)]) {
        return nil;
    }
    id (*shared)(id, SEL) = (id (*)(id, SEL))objc_msgSend;
    return shared((id)cls, @selector(sharedInstance));
}

- (BOOL)getWiFiEnabled:(BOOL *)enabled {
    id controller = [self wifiController];
    if (!controller) {
        return NO;
    }
    if ([controller respondsToSelector:@selector(isWiFiEnabled)]) {
        *enabled = ((BOOL (*)(id, SEL))objc_msgSend)(controller, @selector(isWiFiEnabled));
        return YES;
    }
    if ([controller respondsToSelector:@selector(isPowered)]) {
        *enabled = ((BOOL (*)(id, SEL))objc_msgSend)(controller, @selector(isPowered));
        return YES;
    }
    return NO;
}

- (BOOL)setWiFiEnabled:(BOOL)enabled {
    id controller = [self wifiController];
    if (!controller) {
        return NO;
    }
    if ([controller respondsToSelector:@selector(setWiFiEnabled:)]) {
        ((void (*)(id, SEL, BOOL))objc_msgSend)(controller, @selector(setWiFiEnabled:), enabled);
        return YES;
    }
    if ([controller respondsToSelector:@selector(setPowered:)]) {
        ((void (*)(id, SEL, BOOL))objc_msgSend)(controller, @selector(setPowered:), enabled);
        return YES;
    }
    return NO;
}

- (nullable id)bluetoothController {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dlopen("/System/Library/PrivateFrameworks/BluetoothManager.framework/BluetoothManager", RTLD_LAZY);
    });
    Class cls = NNClass(@"BluetoothManager");
    if (cls && [cls respondsToSelector:@selector(sharedInstance)]) {
        id (*shared)(id, SEL) = (id (*)(id, SEL))objc_msgSend;
        return shared((id)cls, @selector(sharedInstance));
    }
    cls = NNClass(@"SBBluetoothController");
    if (cls && [cls respondsToSelector:@selector(sharedInstance)]) {
        id (*shared)(id, SEL) = (id (*)(id, SEL))objc_msgSend;
        return shared((id)cls, @selector(sharedInstance));
    }
    return nil;
}

- (BOOL)getBluetoothEnabled:(BOOL *)enabled {
    id controller = [self bluetoothController];
    if (!controller) {
        return NO;
    }
    if ([controller respondsToSelector:@selector(isEnabled)]) {
        *enabled = ((BOOL (*)(id, SEL))objc_msgSend)(controller, @selector(isEnabled));
        return YES;
    }
    if ([controller respondsToSelector:@selector(powerState)]) {
        *enabled = ((int (*)(id, SEL))objc_msgSend)(controller, @selector(powerState)) != 0;
        return YES;
    }
    return NO;
}

- (BOOL)setBluetoothEnabled:(BOOL)enabled {
    id controller = [self bluetoothController];
    if (!controller) {
        return NO;
    }
    if ([controller respondsToSelector:@selector(setEnabled:)]) {
        ((void (*)(id, SEL, BOOL))objc_msgSend)(controller, @selector(setEnabled:), enabled);
        return YES;
    }
    if ([controller respondsToSelector:@selector(setPowerState:)]) {
        ((void (*)(id, SEL, BOOL))objc_msgSend)(controller, @selector(setPowerState:), enabled);
        return YES;
    }
    return NO;
}

- (BOOL)setAirplaneMode:(BOOL)enabled {
    id airplane = NNSharedInstance(@"SBAirplaneModeController");
    if (!NNObjectResponds(airplane, @"setInAirplaneMode:")) {
        return NO;
    }
    [(SBAirplaneModeController *)airplane setInAirplaneMode:enabled];
    return YES;
}

- (BOOL)setLowPowerMode:(BOOL)enabled {
    Class detail = NNClass(@"PSLowPowerModeSettingsDetail");
    if (detail && [detail respondsToSelector:@selector(setEnabled:)]) {
        void (*send)(id, SEL, BOOL) = (void (*)(id, SEL, BOOL))objc_msgSend;
        send((id)detail, @selector(setEnabled:), enabled);
        return YES;
    }

    id saver = NNSharedInstance(@"_CDBatterySaver");
    if (NNObjectResponds(saver, @"setPowerMode:error:")) {
        NSError *error = nil;
        BOOL result = [(_CDBatterySaver *)saver setPowerMode:enabled ? 1 : 0 error:&error];
        if (!result && error) {
            NNLogError(@"battery saver failed: %@", error.localizedDescription);
        }
        return result;
    }

    return NO;
}

- (void)saveRecoverySnapshot {
    NSDictionary *snapshot = @{
        @"Active": @(self.sessionActive),
        @"WakeArmed": @(self.wakeArmed),
        @"CachedAirplane": @(self.cachedAirplane),
        @"CachedWiFi": @(self.cachedWiFi),
        @"CachedBluetooth": @(self.cachedBluetooth),
        @"CachedLowPower": @(self.cachedLowPower),
        @"CachedLocked": @(self.cachedLocked),
        @"CachedProximity": @(self.cachedProximity),
        @"ChangedAirplane": @(self.changedAirplane),
        @"ChangedWiFi": @(self.changedWiFi),
        @"ChangedBluetooth": @(self.changedBluetooth),
        @"ChangedLowPower": @(self.changedLowPower),
        @"MutedRinger": @(self.mutedRinger),
        @"CachedRingtoneVolume": @(self.cachedRingtoneVolume),
        @"LockedByUs": @(self.lockedByUs),
        @"ChangedProximity": @(self.changedProximity),
        @"Timestamp": @([[NSDate date] timeIntervalSince1970])
    };
    [NNStateStore saveSnapshot:snapshot];
}

- (void)dealloc {
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                       (__bridge const void *)self,
                                       (__bridge CFStringRef)NNManualHibernateNotification,
                                       NULL);
}

@end
