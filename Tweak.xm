#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NNBatteryMonitor.h"
#import "NNHibernationController.h"
#import "NNLocalSilence.h"
#import "NNWakeGuard.h"

__attribute__((constructor)) static void NightNightInitialize(void) {
    @autoreleasepool {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NNHibernationController sharedInstance] start];
            [[NNBatteryMonitor sharedInstance] start];
            [[NNWakeGuard sharedInstance] start];
            [NNLocalSilence start];
        });
    }
}
