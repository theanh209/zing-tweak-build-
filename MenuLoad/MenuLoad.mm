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
    // TẠO NÚT TRÒN MỞ MENU (Bấm là bung Menu)
    // ==========================================
    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuButton.frame = CGRectMake(50, 100, 50, 50); // Nút tròn 50x50
    
    self.menuButton.layer.cornerRadius = 25.0f; // Bo tròn
    self.menuButton.clipsToBounds = YES;
    self.menuButton.backgroundColor = [UIColor clearColor];
    
    // Viền trắng mờ
    self.menuButton.layer.borderWidth = 2.0f;
    self.menuButton.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.6f].CGColor;
    
    // Chữ hiển thị (Màu đỏ)
    [self.menuButton setTitle:@"Menu" forState:UIControlStateNormal];
    [self.menuButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.menuButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];

    // Gắn sự kiện bấm và kéo thả
    [self.menuButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.menuButton addGestureRecognizer:pan];
    
    [window addSubview:self.menuButton];
}

- (void)toggleMenu {
    if (!self.imguiView) {
        UIWindow *window = self.menuButton.superview;
        if (!window) return;
        
        self.imguiView = [[ImGuiDrawView alloc] init];
        UIView *imguiAsView = (UIView *)self.imguiView; 
        imguiAsView.frame = window.bounds;
        imguiAsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imguiAsView.userInteractionEnabled = YES;
        imguiAsView.hidden = YES; // Ẩn lúc đầu
        [window addSubview:imguiAsView];
    }
    
    isMenuShowing = !isMenuShowing;
    UIView *imguiAsView = (UIView *)self.imguiView;
    
    // Bật/tắt bằng Animation Alpha hoặc Hidden tuỳ mày, tao dùng Hidden cho nhẹ
    imguiAsView.hidden = !isMenuShowing;
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self.menuButton.superview];
    self.menuButton.center = CGPointMake(self.menuButton.center.x + translation.x, self.menuButton.center.y + translation.y);
    [pan setTranslation:CGPointZero inView:self.menuButton.superview];
}

@end
