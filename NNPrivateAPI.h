#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SBAirplaneModeController : NSObject
+ (nullable instancetype)sharedInstance;
- (BOOL)isInAirplaneMode;
- (void)setInAirplaneMode:(BOOL)enabled;
@end

@interface SBBacklightController : NSObject
+ (nullable instancetype)sharedInstance;
- (void)_startFadeOutAnimationFromLockSource:(long long)source;
- (void)turnOnScreenFullyWithBacklightSource:(long long)source;
@end

@interface SBLockScreenManager : NSObject
+ (nullable instancetype)sharedInstance;
- (BOOL)isUILocked;
- (void)lockUIFromSource:(NSUInteger)source withOptions:(nullable NSDictionary *)options;
- (void)unlockUIFromSource:(NSUInteger)source withOptions:(nullable NSDictionary *)options;
@end

@interface PSLowPowerModeSettingsDetail : NSObject
+ (void)setEnabled:(BOOL)enabled;
+ (BOOL)isEnabled;
@end

@interface _CDBatterySaver : NSObject
+ (nullable instancetype)sharedInstance;
- (BOOL)setPowerMode:(long long)mode error:(NSError **)error;
@end

FOUNDATION_EXPORT Class _Nullable NNClass(NSString *name);
FOUNDATION_EXPORT id _Nullable NNSharedInstance(NSString *className);
FOUNDATION_EXPORT BOOL NNObjectResponds(id object, NSString *selectorName);

NS_ASSUME_NONNULL_END
