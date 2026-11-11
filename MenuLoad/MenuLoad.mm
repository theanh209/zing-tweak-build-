// File: MenuLoad/MenuLoad.mm
#import <UIKit/UIKit.h>
#include "Includes.h"
#import "ImGuiDrawView.h"

@interface MenuLoad()
@property (nonatomic, strong) ImGuiDrawView *imguiView;
@property (nonatomic, strong) UIButton *menuButton;
@end

static MenuLoad* extraInfo;
static BOOL isMenuShowing = NO;

@implementation MenuLoad

+ (void)load {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        extraInfo = [[MenuLoad alloc] init];
        [extraInfo setupMenuButton];
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

- (void)setupMenuButton {
    UIWindow *window = [self getActiveWindow];
    if (!window) return;

    // Tạo nút Menu (giống hệt cái cũ của mày)
    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuButton.frame = CGRectMake(50, 100, 60, 60);
    self.menuButton.layer.cornerRadius = 30.0f; 
    self.menuButton.clipsToBounds = YES;
    self.menuButton.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
    self.menuButton.layer.borderWidth = 2.0f;
    self.menuButton.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.6f].CGColor;
    
    [self.menuButton setTitle:@"Menu" forState:UIControlStateNormal];
    [self.menuButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.menuButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];

    [self.menuButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    
    // Thêm tính năng kéo thả nút đi chỗ khác
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.menuButton addGestureRecognizer:pan];
    
    [window addSubview:self.menuButton];
}

- (void)toggleMenu {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 1. Khởi tạo ImGuiView nếu chưa có (Chỉ khởi tạo 1 lần)
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
        
        // 2. Bật/tắt trạng thái
        isMenuShowing = !isMenuShowing;
        UIView *imguiAsView = (UIView *)self.imguiView;
        imguiAsView.hidden = !isMenuShowing;
        
        // 3. Đồng bộ trạng thái với ImGui và bật/tắt render
        [ImGuiDrawView showChange:isMenuShowing];
        [self.imguiView setRenderingPaused:!isMenuShowing];
    });
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self.menuButton.superview];
    self.menuButton.center = CGPointMake(self.menuButton.center.x + translation.x, self.menuButton.center.y + translation.y);
    [pan setTranslation:CGPointZero inView:self.menuButton.superview];
}

@end
