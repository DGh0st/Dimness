#import <BackBoardServices/BKSDisplayBrightness.h>
#import "DimnessController.h"

@interface NSDistributedNotificationCenter : NSNotificationCenter
+(instancetype)defaultCenter;
-(void)postNotificationName:(NSNotificationName)name object:(NSString *)object userInfo:(NSDictionary *)userInfo deliverImmediately:(BOOL)deliverImmediately;
@end

#define BRIGHTNESS_CHANGED_NOTIFICATION @"com.dgh0st.dimness.brightnesschanged"

%group nonspringboard
%hookf(void, "_BKSDisplayBrightnessSet", float brightness, NSInteger unknown) {
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:BRIGHTNESS_CHANGED_NOTIFICATION object:nil userInfo:nil deliverImmediately:YES];
	%orig(brightness, unknown);
}
%end

%group springboard
%hookf(void, "_BKSDisplayBrightnessSet", float brightness, NSInteger unknown) {
	[[DimnessController sharedInstance] setWindowBrightness:brightness];
	%orig(brightness, unknown);
}

// classic flash style screenshoting
%hook SBScreenshotManager
-(void)saveScreenshotsWithCompletion:(void(^)())completion {
	DimnessController *dimnessController = [DimnessController sharedInstance];
	[dimnessController setDisableDimness:YES];

	void (^unhideCompletion)() = ^{
		if (completion != nil)
			completion();
		[dimnessController setDisableDimness:NO];
	};

	// make sure dimness disable changes are being sent to the render server
	dispatch_after(DISPATCH_TIME_NOW, dispatch_get_main_queue(), ^{
		%orig(unhideCompletion);
	});
}
%end

%hook SpringBoard
-(void)takeScreenshot {
	[[DimnessController sharedInstance] setDisableDimness:YES];

	// make sure dimness disable changes are being sent to the render server
	dispatch_after(DISPATCH_TIME_NOW, dispatch_get_main_queue(), ^{
		%orig();
	});
}

-(void)takeScreenshotAndEdit:(BOOL)edit {
	[[DimnessController sharedInstance] setDisableDimness:YES];

	// make sure dimness disable changes are being sent to the render server
	dispatch_after(DISPATCH_TIME_NOW, dispatch_get_main_queue(), ^{
		%orig(edit);
	});
}

-(void)screenCapturer:(id)capturer didCaptureScreenshotsOfScreens:(id)screens {
	[[DimnessController sharedInstance] setDisableDimness:NO];
	%orig(capturer, screens);
}
%end
%end

// potentially hook BKSHIDServicesSetBacklightFactorWithFadeDuration

static id applicationFinishLaunchingObserver = nil;
static id applicationBrightnessChangedObserver = nil;
static id bundleDidLoadObserver = nil;

static void InitializeNonSpringBoardHooks() {
	%init(nonspringboard);
}

%ctor {
	NSArray *args = [[NSProcessInfo processInfo] arguments];
	if (args != nil && args.count != 0) {
		NSString *execPath = args[0];
		if (execPath) {
			BOOL isSpringBoard = [[execPath lastPathComponent] isEqualToString:@"SpringBoard"];
			BOOL isApplicaiton = [execPath rangeOfString:@"/Application"].location != NSNotFound;
			if (isSpringBoard) {
				MSImageRef image = MSGetImageByName("/System/Library/PrivateFrameworks/BackBoardServices.framework/BackBoardServices");
				float (*GetCurrentBrightness)() = MSFindSymbol(image, "_BKSDisplayBrightnessGetCurrent");
				if (GetCurrentBrightness != NULL) {
					void (^UpdateWindowBrightness)(NSNotification *notification) = ^(NSNotification *notification) {
						float brightness = GetCurrentBrightness();
						[[DimnessController sharedInstance] setWindowBrightness:brightness];
					};

					applicationFinishLaunchingObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:UpdateWindowBrightness];
					applicationBrightnessChangedObserver = [[NSDistributedNotificationCenter defaultCenter] addObserverForName:BRIGHTNESS_CHANGED_NOTIFICATION object:nil queue:[NSOperationQueue mainQueue] usingBlock:UpdateWindowBrightness];
				}

				%init(springboard);
			} else if (%c(BKSLocalDefaults)) {
				InitializeNonSpringBoardHooks();
			} else if (isApplicaiton) {
				bundleDidLoadObserver = [[NSNotificationCenter defaultCenter] addObserverForName:NSBundleDidLoadNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
					if ([notification.userInfo[NSLoadedClasses] containsObject:@"BKSLocalDefaults"])
						InitializeNonSpringBoardHooks();
				}];
			}
		}
	}
}

%dtor {
	if (applicationFinishLaunchingObserver != nil)
		[[NSNotificationCenter defaultCenter] removeObserver:applicationFinishLaunchingObserver];

	if (applicationBrightnessChangedObserver != nil)
		[[NSDistributedNotificationCenter defaultCenter] removeObserver:applicationBrightnessChangedObserver];

	if (bundleDidLoadObserver != nil)
		[[NSNotificationCenter defaultCenter] removeObserver:bundleDidLoadObserver];
}
