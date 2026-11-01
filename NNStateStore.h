#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NNStateStore : NSObject

+ (nullable NSDictionary<NSString *, id> *)loadSnapshot;
+ (BOOL)saveSnapshot:(NSDictionary<NSString *, id> *)snapshot;
+ (void)clearSnapshot;

@end

NS_ASSUME_NONNULL_END
