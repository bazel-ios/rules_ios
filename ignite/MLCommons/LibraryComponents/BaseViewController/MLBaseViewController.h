//
// MLBaseViewController.h
// MLCommons
//
// Created by pablo igounet on 21/3/18.
//

#import <UIKit/UIKit.h>

@class MLBehaviourManager;
@protocol MLBehaviourProtocol;

@interface MLBaseViewController : UIViewController

/**
   Let clients add optional behaviors.

   @param behaviourManager used to add those optional behaviours.
 */
- (void)setupBehaviours:(MLBehaviourManager *)behaviourManager;

/**
   Lets client add optional behaviours to the view controller.

   @param behaviour to be added to the view controller.
   @return if the behaviour was successfully added or not (Duplicated required behaviour).
 */
- (BOOL)addBehaviour:(id <MLBehaviourProtocol>)behaviour;

/**
   Lets client remove behaviours to the view controller.

   @param behaviour to be removed to the view controller.
   @return if the behaviour was successfully removed or not(Try to remove a required behaviour).
 */
- (BOOL)removeBehaviour:(id <MLBehaviourProtocol>)behaviour;

/**
    Lets client get behaviour a behaviour of the view controller.

    @param behaviourClass is the class of the behaviour you want to retrive.
    @return behaviour of the behaviourClass or nil if there is no behaviour registred for that class.
 */
- (id <MLBehaviourProtocol>)getBehaviour:(Class)behaviourClass;

/**
   Invoked when view controller is shown from a Deeplink or URL

   @param url The deeplink used to show the
 */
- (void)viewDidAppearForUrl:(NSURL *)url;

@end
