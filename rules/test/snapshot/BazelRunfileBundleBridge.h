#import <Foundation/Foundation.h>

@interface NSBundle (BazelRunfileBundleBridge)

/**
* This method returns the runfile path for a resource abstracting away from how
* it's provided to do something reasonable.
*/
- (NSString *)bazelRunfilePathForResource:(NSString *)resource;

@end

