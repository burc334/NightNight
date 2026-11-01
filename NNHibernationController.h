#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NNHibernationState) {
    NNHibernationStateAwake = 0,
    NNHibernationStatePreparing,
    NNHibernationStateHibernating,
    NNHibernationStateWaking
};

typedef NS_ENUM(NSInteger, NNHibernationReason) {
    NNHibernationReasonAutomatic = 0,
    NNHibernationReasonManual,
    NNHibernationReasonAutoWake,
    NNHibernationReasonCharger
};

@interface NNHibernationController : NSObject

@property (nonatomic, readonly) NNHibernationState state;
@property (nonatomic, readonly, getter=isSessionActive) BOOL sessionActive;

+ (instancetype)sharedInstance;
- (void)start;
- (void)recoverIfNeeded;
- (void)hibernateForReason:(NNHibernationReason)reason;
- (void)wakeForReason:(NNHibernationReason)reason;
- (BOOL)evaluateChargerWake:(BOOL)charging;
- (void)evaluateWakeAtLevel:(NSInteger)level charging:(BOOL)charging;

@end

NS_ASSUME_NONNULL_END
