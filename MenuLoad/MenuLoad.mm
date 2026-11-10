#import <UIKit/UIKit.h>
#include "Includes.h"
#import "ImGuiDrawView.h"

@interface MenuLoad()
@property (nonatomic, strong) ImGuiDrawView *imguiView;
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, assign) BOOL isSetupDone;
- (ImGuiDrawView*) GetImGuiView;
@end

static MenuLoad* extraInfo;
static BOOL isMenuShowing = NO;

@implementation MenuLoad

+ (void)load {
    extraInfo = [[MenuLoad alloc] init];
    extraInfo.isSetupDone = NO;
    
    // Cứ 1 giây kiểm tra 1 lần. Khi nào game vào Menu chính (sau màn Zing) thì mới gắn nút
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:extraInfo selector:@selector(waitForGameToLoad) userInfo:nil repeats:YES];
}

- (void)waitForGameToLoad {
    if (self.isSetupDone) return;

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

    // Chờ 10 giây cho chắc chắn qua màn hình Zing (Loading)
    static int delayCount = 0;
    delayCount++;
    if (delayCount < 10) return; 

    self.isSetupDone = YES;
    
    // ==========================================
    // TẠO NÚT TRÒN (CON KHỈ)
    // ==========================================
    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuButton.frame = CGRectMake(50, 100, 60, 60);
    
    self.menuButton.layer.cornerRadius = 30.0f; 
    self.menuButton.clipsToBounds = YES;
    self.menuButton.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
    self.menuButton.layer.borderWidth = 2.0f;
    self.menuButton.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.5f].CGColor;
    
    NSString *imagePath = @"/var/jb/Library/Application Support/34306jit/logo.png";
    UIImage *logoImage = [UIImage imageWithContentsOfFile:imagePath];
    
    if (logoImage) {
        [self.menuButton setImage:logoImage forState:UIControlStateNormal];
    } else {
        [self.menuButton setTitle:@"M" forState:UIControlStateNormal];
        [self.menuButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }

    [self.menuButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.menuButton addGestureRecognizer:pan];
    
    [window addSubview:self.menuButton];
}

- (void)toggleMenu {
    // Đưa lên Main Thread để khởi tạo Metal an toàn, đéo bị văng
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.imguiView) {
            UIWindow *window = self.menuButton.superview;
            if (!window) return;

            self.imguiView = [[ImGuiDrawView alloc] init];
            UIView *imguiAsView = (UIView *)self.imguiView;
            imguiAsView.frame = window.bounds;
            imguiAsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            imguiAsView.userInteractionEnabled = YES;
            imguiAsView.alpha = 0.0f; // Ẩn lúc đầu
            
            [window addSubview:imguiAsView];
            
            // Đợi 0.1s cho Metal vẽ frame đầu tiên rồi mới fade in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.2 animations:^{
                    imguiAsView.alpha = 1.0f;
                }];
            });
            isMenuShowing = YES;
            
        } else {
            // Nếu đã có thì ẩn/hiện mượt mà
            isMenuShowing = !isMenuShowing;
            UIView *imguiAsView = (UIView *)self.imguiView;
            [UIView animateWithDuration:0.2 animations:^{
                imguiAsView.alpha = isMenuShowing ? 1.0f : 0.0f;
            }];
        }
    });
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
