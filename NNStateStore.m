#import "NNStateStore.h"
#import "NNLog.h"

static NSString *NNSnapshotPath(void) {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.burc334.nightnight.state.plist"];
}

@implementation NNStateStore

+ (nullable NSDictionary<NSString *, id> *)loadSnapshot {
    NSString *path = NNSnapshotPath();
    NSDictionary *snapshot = [NSDictionary dictionaryWithContentsOfFile:path];
    if (![snapshot isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    return snapshot;
}

+ (BOOL)saveSnapshot:(NSDictionary<NSString *, id> *)snapshot {
    NSString *path = NNSnapshotPath();
    NSError *error = nil;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:snapshot
                                                              format:NSPropertyListBinaryFormat_v1_0
                                                             options:0
                                                               error:&error];
    if (!data) {
        NNLogError(@"could not serialize recovery snapshot: %@", error.localizedDescription);
        return NO;
    }
    BOOL result = [data writeToFile:path options:NSDataWritingAtomic error:&error];
    if (!result) {
        NNLogError(@"could not write recovery snapshot: %@", error.localizedDescription);
    }
    return result;
}

+ (void)clearSnapshot {
    NSString *path = NNSnapshotPath();
    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

@end
