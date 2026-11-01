#import "NNSettings.h"
#import "NNConstants.h"

static NSString *const NNEnabledKey = @"Enabled";
static NSString *const NNAutoHibernateKey = @"AutoHibernate";
static NSString *const NNSleepLevelKey = @"SleepLevel";
static NSString *const NNWakeLevelKey = @"WakeLevel";
static NSString *const NNAllowChargingKey = @"AllowCharging";
static NSString *const NNWakeOnChargerKey = @"WakeOnCharger";

static CFPropertyListRef NNCopyPreference(NSString *key) {
    return CFPreferencesCopyValue((__bridge CFStringRef)key,
                                  (__bridge CFStringRef)NNPreferencesDomain,
                                  kCFPreferencesCurrentUser,
                                  kCFPreferencesAnyHost);
}

static void NNSetPreference(NSString *key, CFPropertyListRef value) {
    CFPreferencesSetValue((__bridge CFStringRef)key,
                          value,
                          (__bridge CFStringRef)NNPreferencesDomain,
                          kCFPreferencesCurrentUser,
                          kCFPreferencesAnyHost);
    CFPreferencesSynchronize((__bridge CFStringRef)NNPreferencesDomain,
                             kCFPreferencesCurrentUser,
                             kCFPreferencesAnyHost);
}

static BOOL NNBoolValue(NSString *key, BOOL fallback) {
    CFPropertyListRef value = NNCopyPreference(key);
    if (!value) {
        return fallback;
    }
    BOOL result = [(__bridge_transfer id)value boolValue];
    return result;
}

static NSInteger NNIntegerValue(NSString *key, NSInteger fallback) {
    CFPropertyListRef value = NNCopyPreference(key);
    if (!value) {
        return fallback;
    }
    NSInteger result = [(__bridge_transfer id)value integerValue];
    return result;
}

@implementation NNSettings

+ (BOOL)enabled {
    return NNBoolValue(NNEnabledKey, NNDefaultEnabled);
}

+ (BOOL)autoHibernate {
    return NNBoolValue(NNAutoHibernateKey, NNDefaultAutoHibernate);
}

+ (NSInteger)sleepLevel {
    NSInteger level = NNIntegerValue(NNSleepLevelKey, NNDefaultSleepLevel);
    return MIN(99, MAX(1, level));
}

+ (NSInteger)wakeLevel {
    NSInteger level = NNIntegerValue(NNWakeLevelKey, NNDefaultWakeLevel);
    level = MIN(99, MAX(1, level));
    if (level <= [self sleepLevel]) {
        level = MIN(99, [self sleepLevel] + 1);
    }
    return level;
}

+ (BOOL)allowCharging {
    return NNBoolValue(NNAllowChargingKey, NNDefaultAllowCharging);
}

+ (BOOL)wakeOnCharger {
    return NNBoolValue(NNWakeOnChargerKey, NNDefaultWakeOnCharger);
}

+ (void)setBool:(BOOL)value forKey:(NSString *)key {
    NNSetPreference(key, (__bridge CFPropertyListRef)@(value));
}

+ (void)setInteger:(NSInteger)value forKey:(NSString *)key {
    NNSetPreference(key, (__bridge CFPropertyListRef)@(value));
}

+ (void)resetToDefaults {
    NSArray<NSString *> *keys = @[
        NNEnabledKey,
        NNAutoHibernateKey,
        NNSleepLevelKey,
        NNWakeLevelKey,
        NNAllowChargingKey,
        NNWakeOnChargerKey
    ];
    for (NSString *key in keys) {
        CFPreferencesSetValue((__bridge CFStringRef)key,
                              NULL,
                              (__bridge CFStringRef)NNPreferencesDomain,
                              kCFPreferencesCurrentUser,
                              kCFPreferencesAnyHost);
    }
    CFPreferencesSynchronize((__bridge CFStringRef)NNPreferencesDomain,
                             kCFPreferencesCurrentUser,
                             kCFPreferencesAnyHost);
    [self postChanged];
}

+ (void)postChanged {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                         (__bridge CFStringRef)NNPreferencesChangedNotification,
                                         NULL,
                                         NULL,
                                         true);
}

+ (void)postManualHibernate {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                         (__bridge CFStringRef)NNManualHibernateNotification,
                                         NULL,
                                         NULL,
                                         true);
}

@end
