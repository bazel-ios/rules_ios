//
// MLBaseViewController.m
// MLCommons
//
// Created by pablo igounet on 21/3/18.
//

#import "MLBaseViewController.h"
#import "MLBehaviourManager.h"
#import "MLBehaviourProtocol.h"

@interface MLBaseViewController ()

/**
   View's Behaviour Manager
 */
@property (nonatomic, strong) MLBehaviourManager *behaviourManager;

@end

@implementation MLBaseViewController

- (void)behaviourInit
{
	self.behaviourManager = [[MLBehaviourManager alloc] initWithViewController:self];
	[self setupBehaviours:self.behaviourManager];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self behaviourInit];
	}
	return self;
}

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
	if (!nibBundleOrNil) {
		nibBundleOrNil = [NSBundle bundleForClass:[self class]];
	}

	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		[self behaviourInit];
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self.behaviourManager viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.behaviourManager viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self.behaviourManager viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self.behaviourManager viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[self.behaviourManager viewDidDisappear:animated];
}

- (void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	[self.behaviourManager viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	[self.behaviourManager viewDidLayoutSubviews];
}

- (void)viewDidAppearForUrl:(NSURL *)url
{
	[self.behaviourManager viewDidAppearForUrl:url];
}

- (void)dealloc
{
	[self.behaviourManager viewDealloc];
}

- (BOOL)addBehaviour:(id <MLBehaviourProtocol>)behaviour
{
	return [self.behaviourManager addBehaviour:behaviour];
}

- (BOOL)removeBehaviour:(id <MLBehaviourProtocol>)behaviour
{
	return [self.behaviourManager removeBehaviour:behaviour];
}

- (void)setupBehaviours:(MLBehaviourManager *)behaviourManager
{
	// Those ones who want to add optional behaviours must override this method
}

- (id <MLBehaviourProtocol>)getBehaviour:(Class)behaviourClass
{
	return [self.behaviourManager getBehaviour:behaviourClass];
}

@end
