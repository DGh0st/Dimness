#import "DimnessWindow.h"

#define DIMNESS_WINDOW_LEVEL 9999999
#define DIMNESS_FACTOR 0.5

#define DIMNESS_USER_DEFAULTS @"com.dgh0st.dimness"
#define MAX_DIMNESS_KEY @"MaxDimness"
#define CAN_DISABLE_DIMNESS_KEY @"CanDisableDimness"

%subclass DimnessWindow : SBIgnoredForAutorotationSecureWindow
%property (nonatomic, assign) BOOL canDisableDimness;

-(instancetype)initWithScreen:(UIScreen *)screen debugName:(NSString *)name {
	self = %orig(screen, name);
	if (self != nil) {
		self.windowLevel = DIMNESS_WINDOW_LEVEL;
		self.hidden = NO;

		NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:DIMNESS_USER_DEFAULTS];
		CGFloat maxDimness = [userDefaults objectForKey:MAX_DIMNESS_KEY] ? [[userDefaults objectForKey:MAX_DIMNESS_KEY] floatValue] : DIMNESS_FACTOR;
		self.canDisableDimness = [userDefaults objectForKey:CAN_DISABLE_DIMNESS_KEY] ? [[userDefaults objectForKey:CAN_DISABLE_DIMNESS_KEY] boolValue] : YES;

		UIViewController *viewController = [[UIViewController alloc] init];
		self.rootViewController = viewController;
		self.rootViewController.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:maxDimness];

		[userDefaults release];
		[viewController release];
	}
	return self;
}

%new
-(void)setBrightness:(CGFloat)brightness {
	CGFloat alpha = (1.0 - brightness);
	if (alpha < 0.0)
		alpha = 0.0;
	if (alpha > 1.0)
		alpha = 1.0;
	self.rootViewController.view.alpha = alpha;
}

%new
-(void)setDisableDimness:(CGFloat)disable {
	if (self.canDisableDimness)
		self.rootViewController.view.hidden = disable;
}

%new
-(CGFloat)maxDimness {
	CGFloat whiteness = 0.0;
	CGFloat alpha = 0.0;
	if ([self.rootViewController.view.backgroundColor getWhite:&whiteness alpha:&alpha])
		return alpha;
	return 0.0;
}

%new
-(CGFloat)currentDimness {
	return self.rootViewController.view.alpha;
}

-(BOOL)_ignoresHitTest {
	return YES;
}
%end
