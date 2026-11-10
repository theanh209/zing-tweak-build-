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
    // TẠO NÚT TRÒN
    // ==========================================
    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuButton.frame = CGRectMake(50, 100, 60, 60); // Kích thước 60x60
    
    // Bo tròn nút, viền trắng mờ, nền trong suốt
    self.menuButton.layer.cornerRadius = 30.0f; 
    self.menuButton.clipsToBounds = YES;
    self.menuButton.backgroundColor = [UIColor clearColor];
    self.menuButton.layer.borderWidth = 2.0f;
    self.menuButton.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.5f].CGColor;
    
    // --- LOAD ẢNH TỪ FILE ---
    // Tìm đường dẫn file logo.png (không cần đuôi .png trong tên resource)
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"logo" ofType:@"png"];
    UIImage *logoImage = nil;
    
    if (bundlePath) {
        logoImage = [UIImage imageWithContentsOfFile:bundlePath];
    }
    
    if (logoImage) {
        [self.menuButton setImage:logoImage forState:UIControlStateNormal];
    } else {
        // Fallback nếu tìm không thấy ảnh
        [self.menuButton setTitle:@"M" forState:UIControlStateNormal];
        [self.menuButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    // ------------------------------------------

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
        imguiAsView.hidden = YES; 
        [window addSubview:imguiAsView];
    }
    isMenuShowing = !isMenuShowing;
    UIView *imguiAsView = (UIView *)self.imguiView;
    imguiAsView.hidden = !isMenuShowing;
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
