#import <Foundation/Foundation.h>


/** 
* This method returns the runfile path for a resource abstracting away from
* how it's provided to do something reasonable.
*
* Consider handling the relative path here correctly for devs.
*/
FOUNDATION_EXTERN NSString *BazelRunfilePathForResource(NSString *resource);
