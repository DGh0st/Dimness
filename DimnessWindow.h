#import "SBIgnoredForAutorotationSecureWindow.h"

@interface DimnessWindow : SBIgnoredForAutorotationSecureWindow
@property (nonatomic, assign) BOOL canDisableDimness;
-(instancetype)initWithScreen:(UIScreen *)screen debugName:(NSString *)name;
-(void)setBrightness:(CGFloat)brightness;
-(void)setDisableDimness:(CGFloat)disable;
-(CGFloat)maxDimness;
-(CGFloat)currentDimness;
@end
