//
// MLBehaviourManager.h
// MLCommons
//
// Created by pablo igounet on 21/3/18.
//

#import <Foundation/Foundation.h>
#import "MLBehaviourProtocol.h"
#import "MLBaseViewController.h"

@interface MLBehaviourManager : NSObject
/**
   Initializer

   @param viewController where the behaviours are going to be applied.
   @return returns the instance of the vBehaviourManager and add the required behaviours to the view controller.
 */
- (instancetype)initWithViewController:(MLBaseViewController *)viewController;

/**
   Lets client add required behaviours for all the view controllers in the app.

   @param behaviour to be added to all the view controllers.
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
   Lets the client get a behaviour to configure it.

   @param behaviourClass is the class of the behaviour you want to retrive.
   @return behaviour of the behaviourClass or nil if there is no behaviour registred for that class.
 */
- (id <MLBehaviourProtocol>)getBehaviour:(Class)behaviourClass;

/**
   Life cycle events where the behaviours are going to be executed.
 */
- (void)viewDidLoad;
- (void)viewWillAppear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;
- (void)viewDidDisappear:(BOOL)animated;
- (void)viewWillLayoutSubviews;
- (void)viewDidLayoutSubviews;
- (void)viewDealloc;
- (void)viewDidAppearForUrl:(NSURL *)url;

@end
