#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NNWakeGuard : NSObject

+ (instancetype)sharedInstance;
- (void)start;
- (void)handleVolumePress;

@end

NS_ASSUME_NONNULL_END
