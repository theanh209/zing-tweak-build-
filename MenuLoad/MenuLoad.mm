#import <UIKit/UIKit.h>
#include "Includes.h"
#import "ImGuiDrawView.h"

@interface MenuLoad()
@property (nonatomic, strong) ImGuiDrawView *imguiView;
- (ImGuiDrawView*) GetImGuiView;
@end

static MenuLoad* extraInfo;

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

    // Gắn View vẽ ImGui đè lên màn hình game
    self.imguiView = [[ImGuiDrawView alloc] init];
    UIView *imguiAsView = (UIView *)self.imguiView; 
    imguiAsView.frame = window.bounds;
    imguiAsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imguiAsView.userInteractionEnabled = YES;
    [window addSubview:imguiAsView];
}

- (ImGuiDrawView*) GetImGuiView {
    return self.imguiView;
}

@end
