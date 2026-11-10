#import <UIKit/UIKit.h>
#include "Includes.h"
#import "ImGuiDrawView.h"

@interface MenuLoad()
@property (nonatomic, strong) ImGuiDrawView *imguiView;
@property (nonatomic, strong) UIButton *menuButton;
- (ImGuiDrawView*) GetImGuiView;
@end

static MenuLoad* extraInfo;
static BOOL isMenuShowing = NO;

@implementation MenuLoad

+ (void)load {
    // Chờ game load xong UI (3 giây)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        extraInfo = [[MenuLoad alloc] init];
        [extraInfo setupMenu];
    });
}

- (void)setupMenu {
    UIWindow *window = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *w in scene.windows) {
                    if (w.isKeyWindow) { window = w; break; }
                }
            }
        }
    }
    if (!window) window = [UIApplication sharedApplication].keyWindow;
    if (!window) return;

    // ==========================================
    // 1. TẠO NÚT BẤM (ICON CON KHỈ)
    // ==========================================
    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuButton.frame = CGRectMake(50, 100, 60, 60);
    
    // Style: Viền trắng, bo góc
    self.menuButton.layer.cornerRadius = 30.0f; 
    self.menuButton.clipsToBounds = YES;
    self.menuButton.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
    self.menuButton.layer.borderWidth = 2.0f;
    self.menuButton.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.5f].CGColor;
    
    // Load ảnh từ Rootless Path
    NSString *imagePath = @"/var/jb/Library/Application Support/34306jit/logo.png";
    UIImage *logoImage = [UIImage imageWithContentsOfFile:imagePath];
    if (logoImage) {
        [self.menuButton setImage:logoImage forState:UIControlStateNormal];
    } else {
        [self.menuButton setTitle:@"M" forState:UIControlStateNormal];
        [self.menuButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }

    // Sự kiện bấm và kéo thả
    [self.menuButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.menuButton addGestureRecognizer:pan];
    
    [window addSubview:self.menuButton];
}

- (void)toggleMenu {
    // Tạo ImGui View nếu chưa có (Lazy load, an toàn)
    if (!self.imguiView) {
        UIWindow *window = self.menuButton.superview;
        if (!window) return;
        
        self.imguiView = [[ImGuiDrawView alloc] init];
        UIView *imguiAsView = (UIView *)self.imguiView; 
        imguiAsView.frame = window.bounds;
        imguiAsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imguiAsView.userInteractionEnabled = YES;
        imguiAsView.alpha = 0.0f; // Bắt đầu ẩn
        [window addSubview:imguiAsView];
    }
    
    isMenuShowing = !isMenuShowing;
    UIView *imguiAsView = (UIView *)self.imguiView;
    
    // Bật/tắt bằng Alpha để tránh crash Metal
    [UIView animateWithDuration:0.2 animations:^{
        imguiAsView.alpha = isMenuShowing ? 1.0f : 0.0f;
    }];
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self.menuButton.superview];
    self.menuButton.center = CGPointMake(self.menuButton.center.x + translation.x, self.menuButton.center.y + translation.y);
    [pan setTranslation:CGPointZero inView:self.menuButton.superview];
}

- (ImGuiDrawView*) GetImGuiView {
    return self.imguiView;
}

@end
