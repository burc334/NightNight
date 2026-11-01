#import "NNPrivateAPI.h"
#import <objc/message.h>
#import <objc/runtime.h>

Class _Nullable NNClass(NSString *name) {
    if (name.length == 0) {
        return Nil;
    }
    Class cls = NSClassFromString(name);
    if (!cls) {
        cls = objc_getClass(name.UTF8String);
    }
    return cls;
}

id _Nullable NNSharedInstance(NSString *className) {
    Class cls = NNClass(className);
    if (!cls || ![cls respondsToSelector:@selector(sharedInstance)]) {
        return nil;
    }
    id (*send)(id, SEL) = (id (*)(id, SEL))objc_msgSend;
    return send((id)cls, @selector(sharedInstance));
}

BOOL NNObjectResponds(id object, NSString *selectorName) {
    if (!object || selectorName.length == 0) {
        return NO;
    }
    return [object respondsToSelector:NSSelectorFromString(selectorName)];
}
