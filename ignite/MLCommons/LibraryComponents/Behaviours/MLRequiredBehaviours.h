//
// MLRequiredBehaviours.h
// MLCommons
//
// Created by pablo igounet on 5/4/18.
//

#import <Foundation/Foundation.h>
@protocol MLBehaviourProtocol;

@interface MLRequiredBehaviours : NSObject

/**
   Lets client add all the required behaviours for all the view controllers in the app.

   @param behaviours to be added to all the view controllers.
 */
+ (void)addRequiredBehaviours:(NSArray <id <MLBehaviourProtocol> > *)behaviours;

/**
   Lets the client get the dictionary of required behaviours.

   @return the dictionary of required behaviours
 */
+ (NSMutableDictionary <NSString *, id <MLBehaviourProtocol> > *)requiredBehaviours;

@end
