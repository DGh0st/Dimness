#import <UIKit/UIWindow.h>

@interface SBIgnoredForAutorotationSecureWindow : UIWindow // iOS 11 - 13
-(instancetype)initWithScreen:(UIScreen *)screen debugName:(NSString *)name; // iOS 11 - 13
@end
