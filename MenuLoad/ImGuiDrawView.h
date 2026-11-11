/*
IOS Theos Template Komaru
Jailed (NoJB) Mod Menu Template for iOS Games
By aq9
https://github.com/VenerableCode/iOS-Theos-ModMenuTemp-NoJB
*/

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface ImGuiDrawView : UIViewController

+ (void)showChange:(BOOL)open;
+ (BOOL)isMenuShowing;
- (void)updateIOWithTouchEvent:(UIEvent *)event;

// THÊM DÒNG NÀY ĐỂ FIX LỖI BUILD
- (void)setRenderingPaused:(BOOL)paused;

@end

NS_ASSUME_NONNULL_END
