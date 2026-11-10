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
    // Đợi 3 giây cho game load xong UI rồi mới setup
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
    // 1. TẠO IMGUI VIEW (ẨN BẰNG ALPHA)
    // ==========================================
    self.imguiView = [[ImGuiDrawView alloc] init];
    UIView *imguiAsView = (UIView *)self.imguiView;
    imguiAsView.frame = window.bounds;
    imguiAsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imguiAsView.userInteractionEnabled = YES;
    
    // QUAN TRỌNG: Ẩn bằng alpha thay vì hidden để tránh lỗi crash khi bật lại
    imguiAsView.alpha = 0.0f; 
    
    [window addSubview:imguiAsView];

    // ==========================================
    // 2. TẠO NÚT TRÒN (CON KHỈ)
    // ==========================================
    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuButton.frame = CGRectMake(50, 100, 60, 60);
    
    // Style: Nền trong suốt, viền trắng mờ, bo góc
    self.menuButton.layer.cornerRadius = 30.0f; 
    self.menuButton.clipsToBounds = YES;
    self.menuButton.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
    self.menuButton.layer.borderWidth = 2.0f;
    self.menuButton.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.5f].CGColor;
    
    // Tìm ảnh trong đường dẫn Rootless
    NSString *imagePath = @"/var/jb/Library/Application Support/34306jit/logo.png";
    UIImage *logoImage = [UIImage imageWithContentsOfFile:imagePath];
    
    if (logoImage) {
        [self.menuButton setImage:logoImage forState:UIControlStateNormal];
    } else {
        [self.menuButton setTitle:@"M" forState:UIControlStateNormal];
        [self.menuButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }

    // Gắn sự kiện bấm và kéo thả
    [self.menuButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.menuButton addGestureRecognizer:pan];
    
    [window addSubview:self.menuButton];
}

- (void)toggleMenu {
    if (!self.imguiView) return;
    
    isMenuShowing = !isMenuShowing;
    UIView *imguiAsView = (UIView *)self.imguiView;
    
    // Hiệu ứng mờ dần (Fade in/out) tránh giật lag
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
