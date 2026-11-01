#import "NNLocalSilence.h"
#import "NNHibernationController.h"
#import "NNPrivateAPI.h"

#import <objc/runtime.h>
#import <string.h>
#import <substrate.h>

static void (*NNOriginalWillPresentNotification)(id, SEL, id, id, BOOL);

static void NNWillPresentNotificationHook(id self, SEL _cmd, id destination,
                                          id request, BOOL suppressAlerts) {
    if ([NNLocalSilence shouldSilence]) {
        suppressAlerts = YES;
    }
    if (NNOriginalWillPresentNotification) {
        NNOriginalWillPresentNotification(self, _cmd, destination, request, suppressAlerts);
    }
}

@implementation NNLocalSilence

+ (BOOL)shouldSilence {
    return [[NNHibernationController sharedInstance] isSessionActive];
}

+ (void)start {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class dispatcherClass = NNClass(@"NCNotificationDispatcher");
        SEL selector = NSSelectorFromString(@"destination:willPresentNotificationRequest:suppressAlerts:");
        Method method = class_getInstanceMethod(dispatcherClass, selector);
        const char *types = method ? method_getTypeEncoding(method) : NULL;
        if (method && types && strcmp(types, "v36@0:8@16@24B32") == 0) {
            MSHookMessageEx(dispatcherClass,
                            selector,
                            (IMP)NNWillPresentNotificationHook,
                            (IMP *)&NNOriginalWillPresentNotification);
        }
    });
}

@end
