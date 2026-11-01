#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NNSettings : NSObject

+ (BOOL)enabled;
+ (BOOL)autoHibernate;
+ (NSInteger)sleepLevel;
+ (NSInteger)wakeLevel;
+ (BOOL)allowCharging;
+ (BOOL)wakeOnCharger;

+ (void)setBool:(BOOL)value forKey:(NSString *)key;
+ (void)setInteger:(NSInteger)value forKey:(NSString *)key;
+ (void)resetToDefaults;
+ (void)postChanged;
+ (void)postManualHibernate;

@end

NS_ASSUME_NONNULL_END
