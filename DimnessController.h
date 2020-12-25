@class DimnessWindow;

@interface DimnessController : NSObject
@property (nonatomic, retain) DimnessWindow *dimnessWindow;
+(instancetype)sharedInstance;
-(void)setWindowBrightness:(CGFloat)brightness;
-(void)setDisableDimness:(BOOL)disable;
@end
