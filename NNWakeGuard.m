#import "NNWakeGuard.h"
#import "NNConstants.h"
#import "NNHibernationController.h"
#import "NNLog.h"
#import "NNPrivateAPI.h"

#import <objc/runtime.h>
#import <string.h>
#import <substrate.h>

static BOOL NNHookMethod4(Class cls, SEL selector, IMP hook, IMP *original,
                         NSArray<NSString *> *allowedArgumentTypes) {
    if (!cls || !class_getInstanceMethod(cls, selector)) {
        return NO;
    }
    NSMethodSignature *signature = [cls instanceMethodSignatureForSelector:selector];
    if (!signature || signature.numberOfArguments != 4 ||
        strcmp(signature.methodReturnType, "v") != 0) {
        NNLogError(@"unexpected 4-arg signature for %@", NSStringFromSelector(selector));
        return NO;
    }
    for (NSUInteger index = 2; index < 4; index++) {
        NSString *actualType = [NSString stringWithUTF8String:[signature getArgumentTypeAtIndex:index]];
        if (![allowedArgumentTypes containsObject:actualType]) {
            NNLogError(@"unexpected 4-arg argument type for %@: %@",
                       NSStringFromSelector(selector), actualType);
            return NO;
        }
    }
    MSHookMessageEx(cls, selector, hook, original);
    return YES;
}

static BOOL NNHookMethod(Class cls, SEL selector, IMP hook, IMP *original,
                         NSArray<NSString *> *allowedArgumentTypes) {
    if (!cls || !class_getInstanceMethod(cls, selector)) {
        return NO;
    }
    NSMethodSignature *signature = [cls instanceMethodSignatureForSelector:selector];
    if (!signature || signature.numberOfArguments != 3 ||
        strcmp(signature.methodReturnType, "v") != 0) {
        NNLogError(@"unexpected signature for %@", NSStringFromSelector(selector));
        return NO;
    }
    NSString *actualType = [NSString stringWithUTF8String:[signature getArgumentTypeAtIndex:2]];
    if (allowedArgumentTypes && ![allowedArgumentTypes containsObject:actualType]) {
        NNLogError(@"unexpected argument type for %@: %@",
                   NSStringFromSelector(selector), actualType);
        return NO;
    }
    MSHookMessageEx(cls, selector, hook, original);
    return YES;
}

static void (*NNOriginalVolumePress)(id, SEL, id);
static void (*NNOriginalTapToWake)(id, SEL, id);
static void (*NNOriginalPencilToWake)(id, SEL, id);
static void (*NNOriginalLiftToWake)(id, SEL, id, id);
static void (*NNOriginalBacklightOn)(id, SEL, long long);
static void (*NNOriginalBacklightState)(id, SEL, long long, long long);
static void (*NNOriginalUndim)(id, SEL, long long);

static BOOL NNIsHibernating(void) {
    return [[NNHibernationController sharedInstance] isSessionActive];
}

static void NNVolumePressHook(id self, SEL _cmd, id press) {
    if (NNIsHibernating()) {
        [[NNWakeGuard sharedInstance] handleVolumePress];
        return;
    }
    if (NNOriginalVolumePress) {
        NNOriginalVolumePress(self, _cmd, press);
    }
}

static void NNTapToWakeHook(id self, SEL _cmd, id recognizer) {
    if (NNIsHibernating()) {
        return;
    }
    if (NNOriginalTapToWake) {
        NNOriginalTapToWake(self, _cmd, recognizer);
    }
}

static void NNPencilToWakeHook(id self, SEL _cmd, id recognizer) {
    if (NNIsHibernating()) {
        return;
    }
    if (NNOriginalPencilToWake) {
        NNOriginalPencilToWake(self, _cmd, recognizer);
    }
}

static void NNLiftToWakeHook(id self, SEL _cmd, id manager, id event) {
    if (NNIsHibernating()) {
        return;
    }
    if (NNOriginalLiftToWake) {
        NNOriginalLiftToWake(self, _cmd, manager, event);
    }
}

static void NNBacklightOnHook(id self, SEL _cmd, long long source) {
    if (NNIsHibernating()) {
        return;
    }
    if (NNOriginalBacklightOn) {
        NNOriginalBacklightOn(self, _cmd, source);
    }
}

static void NNBacklightStateHook(id self, SEL _cmd, long long state, long long source) {
    if (NNIsHibernating() && state != 0) {
        return;
    }
    if (NNOriginalBacklightState) {
        NNOriginalBacklightState(self, _cmd, state, source);
    }
}

static void NNUndimHook(id self, SEL _cmd, long long source) {
    if (NNIsHibernating()) {
        return;
    }
    if (NNOriginalUndim) {
        NNOriginalUndim(self, _cmd, source);
    }
}

@interface NNWakeGuard ()
@property (nonatomic) BOOL started;
@property (nonatomic) NSUInteger pressCount;
@property (nonatomic) NSUInteger pressGeneration;
@end

@implementation NNWakeGuard

+ (instancetype)sharedInstance {
    static NNWakeGuard *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[NNWakeGuard alloc] init];
    });
    return shared;
}

- (void)start {
    if (self.started) {
        return;
    }
    self.started = YES;

    Class volumeClass = NNClass(@"SBVolumeHardwareButton");
    NNHookMethod(volumeClass,
                 NSSelectorFromString(@"volumeIncreasePress:"),
                 (IMP)NNVolumePressHook,
                 (IMP *)&NNOriginalVolumePress,
                 @[@"@"]);

    Class tapClass = NNClass(@"SBTapToWakeController");
    NNHookMethod(tapClass,
                 NSSelectorFromString(@"tapToWakeDidRecognize:"),
                 (IMP)NNTapToWakeHook,
                 (IMP *)&NNOriginalTapToWake,
                 @[@"@"]);
    NNHookMethod(tapClass,
                 NSSelectorFromString(@"pencilToWakeDidRecognize:"),
                 (IMP)NNPencilToWakeHook,
                 (IMP *)&NNOriginalPencilToWake,
                 @[@"@"]);

    Class liftClass = NNClass(@"SBLiftToWakeController");
    NNHookMethod4(liftClass,
                  NSSelectorFromString(@"wakeGestureManager:didUpdateWakeGestureEvent:"),
                  (IMP)NNLiftToWakeHook,
                  (IMP *)&NNOriginalLiftToWake,
                  @[@"@", @"@"]);

    Class backlightClass = NNClass(@"SBBacklightController");
    NNHookMethod(backlightClass,
                 NSSelectorFromString(@"turnOnScreenFullyWithBacklightSource:"),
                 (IMP)NNBacklightOnHook,
                 (IMP *)&NNOriginalBacklightOn,
                 @[@"q", @"Q"]);
    NNHookMethod4(backlightClass,
                  NSSelectorFromString(@"setBacklightState:source:"),
                  (IMP)NNBacklightStateHook,
                  (IMP *)&NNOriginalBacklightState,
                  @[@"q", @"Q"]);
    NNHookMethod(backlightClass,
                 NSSelectorFromString(@"_undimFromSource:"),
                 (IMP)NNUndimHook,
                 (IMP *)&NNOriginalUndim,
                 @[@"q", @"Q"]);
}

- (void)handleVolumePress {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleVolumePress];
        });
        return;
    }

    NNHibernationController *controller = [NNHibernationController sharedInstance];
    if (![controller isSessionActive]) {
        return;
    }

    self.pressCount += 1;
    NSUInteger generation = ++self.pressGeneration;

    if (self.pressCount >= NNVolumeWakePressCount) {
        self.pressCount = 0;
        [controller wakeForReason:NNHibernationReasonManual];
        return;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 (int64_t)(NNVolumeWakeResetDelay * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        if (generation == self.pressGeneration) {
            self.pressCount = 0;
        }
    });
}

@end
