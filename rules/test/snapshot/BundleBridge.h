#import <Foundation/Foundation.h>

@interface NSBundle (BazelBundleBridge)

- (NSString *)bazelRunfilePathForResource:(NSString *)resource;

@end

