#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NNBatteryMonitor : NSObject

@property (nonatomic, readonly) NSInteger currentLevel;
@property (nonatomic, readonly, getter=isCharging) BOOL charging;
@property (nonatomic) BOOL armed;

+ (instancetype)sharedInstance;
- (void)start;
- (void)stop;
- (void)evaluateNow;

@end

NS_ASSUME_NONNULL_END
