// File: MenuLoad/MenuLoad.mm
#import <UIKit/UIKit.h>
#include "Includes.h"
#import "ImGuiDrawView.h"

@interface MenuLoad()
@property (nonatomic, strong) ImGuiDrawView *imguiView;
@end

static MenuLoad* extraInfo;
static BOOL isMenuShowing = NO;

@implementation MenuLoad

+ (void)load {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        extraInfo = [[MenuLoad alloc] init];
        [extraInfo setupGesture];
    });
}

- (UIWindow *)getActiveWindow {
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow) return window;
                }
            }
        }
    }
    return [UIApplication sharedApplication].keyWindow;
}

- (void)setupGesture {
    UIWindow *window = [self getActiveWindow];
    if (!window) return;

    // Vuốt 3 ngón tay từ trái sang phải để MỞ menu
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toggleMenu)];
    swipeRight.numberOfTouchesRequired = 3;
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    // Vuốt 3 ngón tay từ phải sang trái để ĐÓNG menu
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toggleMenu)];
    swipeLeft.numberOfTouchesRequired = 3;
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;

    [window addGestureRecognizer:swipeRight];
    [window addGestureRecognizer:swipeLeft];
}

- (void)toggleMenu {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.imguiView) {
            UIWindow *window = [self getActiveWindow];
            if (!window) return;
            
            self.imguiView = [[ImGuiDrawView alloc] init];
            UIView *imguiAsView = (UIView *)self.imguiView; 
            imguiAsView.frame = window.bounds;
            imguiAsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            imguiAsView.userInteractionEnabled = YES;
            imguiAsView.hidden = YES; 
            [window addSubview:imguiAsView];
        }
        
        isMenuShowing = !isMenuShowing;
        UIView *imguiAsView = (UIView *)self.imguiView;
        imguiAsView.hidden = !isMenuShowing;
        
        // FIX: Đồng bộ trạng thái với ImGui
        [ImGuiDrawView showChange:isMenuShowing];
        
        // FIX: Bật/tắt vòng lặp render của Metal
        if (isMenuShowing) {
            self.imguiView.metalView.paused = NO;
        } else {
            self.imguiView.metalView.paused = YES;
        }
    });
}

@end
