#import "NSDictionary+MLKeyWithRange.h"

@implementation NSDictionary (MLKeyWithRange)

- (nullable id)firstValueForKeyInRangeOfString:(NSString *)stringValue;
{
	NSArray *allKeysInRangeOfString = [self allKeysInRangeOfString:stringValue];
	NSString *firstKeyInRangeOfStringValue = [[self sortArrayByLenghtDescending:allKeysInRangeOfString] firstObject];
	return firstKeyInRangeOfStringValue ? [self valueForKey:firstKeyInRangeOfStringValue] : nil;
}

- (NSArray *)allKeysInRangeOfString:(NSString *)stringValue
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ CONTAINS SELF", stringValue];
	return [[self allKeys] filteredArrayUsingPredicate:predicate];
}

- (NSArray *)sortArrayByLenghtDescending:(NSArray *)array
{
	return [array sortedArrayUsingComparator: ^NSComparisonResult (NSString *_Nonnull key1, NSString *_Nonnull key2) {
	    if (key1.length > key2.length) {
	        return NSOrderedAscending;
		}
	    if (key1.length < key2.length) {
	        return NSOrderedDescending;
		}
	    return NSOrderedSame;
	}];
}

@end
