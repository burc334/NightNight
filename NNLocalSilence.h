#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NNLocalSilence : NSObject

+ (void)start;
+ (BOOL)shouldSilence;

@end

NS_ASSUME_NONNULL_END
