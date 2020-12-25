#import "DimnessController.h"
#import "DimnessWindow.h"

@implementation DimnessController
+(instancetype)sharedInstance {
	static DimnessController *_sharedController = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedController = [[DimnessController alloc] init];
	});
	return _sharedController;
}

-(instancetype)init {
	self = [super init];
	if (self != nil)
		self.dimnessWindow = [[%c(DimnessWindow) alloc] initWithScreen:[UIScreen mainScreen] debugName:@"DimnessWindow"];
	return self;
}

-(void)setWindowBrightness:(CGFloat)brightness {
	[self.dimnessWindow setBrightness:brightness];
}

-(void)setDisableDimness:(BOOL)disable {
	[self.dimnessWindow setDisableDimness:disable];
}

-(void)dealloc {
	[self.dimnessWindow release];
	self.dimnessWindow = nil;

	[super dealloc];
}
@end
