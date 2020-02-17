//
// MLBaseBehaviour.h
// MLCommons
//
// Created by pablo igounet on 21/3/18.
//

#import <Foundation/Foundation.h>
#import "MLBehaviourProtocol.h"

@interface MLBaseBehaviour : NSObject <MLBehaviourProtocol>

/**
   ViewController where the behaviours are going to be applied.
 */
@property (nonatomic, weak) MLBaseViewController *viewController;

@end
