//
// MLBehaviourProtocol.h
// MLCommons
//
// Created by pablo igounet on 21/3/18.
//
#import "MLBaseViewController.h"

@protocol MLBehaviourProtocol <NSObject>

/**
   Lets the client set the viewController where the behaviour is going to be applied.

   @param viewController where the behaviour is going to be applied.
 */
- (void)setViewController:(MLBaseViewController *)viewController;

/**
   Life cycle events where the behaviours are going to be executed.
   If you are using the BaseBehaviour you'll only need to override the ones where yo want to trigger your behaviour.
 */
- (void)viewDidLoad;
- (void)viewWillAppear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;
- (void)viewDidDisappear:(BOOL)animated;
- (void)viewWillLayoutSubviews;
- (void)viewDidLayoutSubviews;
- (void)viewDealloc;

/**
   Invoked when view controller has been shown from a url
 */
- (void)viewDidAppearForUrl:(NSURL *)url;

@end
