//
// MLRequiredBehaviours.m
// MLCommons
//
// Created by pablo igounet on 5/4/18.
//

#import "MLRequiredBehaviours.h"
#import "MLBehaviourProtocol.h"

static NSMutableDictionary <NSString *, id <MLBehaviourProtocol> > *_requiredBehaviours;

@implementation MLRequiredBehaviours

+ (NSMutableDictionary <NSString *, id <MLBehaviourProtocol> > *)requiredBehaviours
{
	static dispatch_once_t _onceToken;
	dispatch_once(&_onceToken, ^{
		_requiredBehaviours = [[NSMutableDictionary alloc] init];
	});

	return _requiredBehaviours;
}

+ (void)addRequiredBehaviours:(NSArray <id <MLBehaviourProtocol> > *)behaviours
{
	for (id <MLBehaviourProtocol> behaviour in behaviours) {
		NSString *key = NSStringFromClass([behaviour class]);
		// You can't override a required behaviour
		if (![[MLRequiredBehaviours requiredBehaviours] objectForKey:key]) {
			[[MLRequiredBehaviours requiredBehaviours] setObject:behaviour forKey:key];
		}
	}
}

+ (void)cleanRequiredBehaviours
{
	_requiredBehaviours = [[NSMutableDictionary alloc] init];
}

@end
