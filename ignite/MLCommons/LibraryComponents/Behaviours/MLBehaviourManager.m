//
// MLBehaviourManager.m
// MLCommons
//
// Created by pablo igounet on 21/3/18.
//

#import "MLBehaviourManager.h"
#import "MLRequiredBehaviours.h"

@interface MLBehaviourManager ()

@property (nonatomic, strong) NSMutableDictionary <NSString *, id <MLBehaviourProtocol> > *behaviours;
@property (nonatomic, weak) MLBaseViewController *viewController;

@end

@implementation MLBehaviourManager

- (instancetype)initWithViewController:(MLBaseViewController *)viewController
{
	self = [super init];

	if (self) {
		self.behaviours = [[NSMutableDictionary alloc] init];
		self.viewController = viewController;
		for (id <MLBehaviourProtocol> behaviour in [[MLRequiredBehaviours requiredBehaviours] allValues]) {
			id <MLBehaviourProtocol> requiredBehaviour = [[[behaviour class] alloc] init];
			[self.behaviours setObject:requiredBehaviour forKey:NSStringFromClass([requiredBehaviour class])];
			[requiredBehaviour setViewController:self.viewController];
		}
	}

	return self;
}

- (void)viewDidLoad
{
	for (id <MLBehaviourProtocol> behaviour in [[self behaviours] allValues]) {
		[behaviour viewDidLoad];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	for (id <MLBehaviourProtocol> behaviour in [[self behaviours] allValues]) {
		[behaviour viewWillAppear:animated];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	for (id <MLBehaviourProtocol> behaviour in [[self behaviours] allValues]) {
		[behaviour viewDidAppear:animated];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	for (id <MLBehaviourProtocol> behaviour in [[self behaviours] allValues]) {
		[behaviour viewWillDisappear:animated];
	}
}

- (void)viewDidDisappear:(BOOL)animated
{
	for (id <MLBehaviourProtocol> behaviour in [[self behaviours] allValues]) {
		[behaviour viewDidDisappear:animated];
	}
}

- (void)viewWillLayoutSubviews
{
	for (id <MLBehaviourProtocol> behaviour in [[self behaviours] allValues]) {
		[behaviour viewWillLayoutSubviews];
	}
}

- (void)viewDidLayoutSubviews
{
	for (id <MLBehaviourProtocol> behaviour in [[self behaviours] allValues]) {
		[behaviour viewDidLayoutSubviews];
	}
}

- (void)viewDealloc
{
	for (id <MLBehaviourProtocol> behaviour in [[self behaviours] allValues]) {
		[behaviour viewDealloc];
	}
}

- (void)viewDidAppearForUrl:(NSURL *)url
{
	for (id <MLBehaviourProtocol> behaviour in [[self behaviours] allValues]) {
		[behaviour viewDidAppearForUrl:url];
	}
}

- (BOOL)addBehaviour:(id <MLBehaviourProtocol>)behaviour
{
	// You can't override a required behaviour, otherwise the last behaviour of the same class will remain.
	if (![[MLRequiredBehaviours requiredBehaviours] objectForKey:NSStringFromClass([behaviour class])]) {
		[self.behaviours setObject:behaviour forKey:NSStringFromClass([behaviour class])];
		[behaviour setViewController:self.viewController];
		return YES;
	}
	return NO;
}

- (BOOL)removeBehaviour:(id <MLBehaviourProtocol>)behaviour
{
	// You can't remove a required behaviour.
	if (![[MLRequiredBehaviours requiredBehaviours] objectForKey:NSStringFromClass([behaviour class])]) {
		[self.behaviours removeObjectForKey:NSStringFromClass([behaviour class])];
		return YES;
	}
	return NO;
}

- (id <MLBehaviourProtocol>)getBehaviour:(Class)behaviourClass
{
	return [self.behaviours objectForKey:NSStringFromClass(behaviourClass)];
}

@end
