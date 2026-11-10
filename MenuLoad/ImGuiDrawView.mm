// File: MenuLoad/ImGuiDrawView.mm
#import "ImGuiDrawView.h"
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#include "../ImGui/imgui.h"
#include "../ImGui/imgui_impl_metal.h"
#include "UserMenu.h"

@interface ImGuiDrawView () <MTKViewDelegate>
@property (nonatomic, strong) MTKView *metalView;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, assign) BOOL imguiReady;
@end

@implementation ImGuiDrawView

static bool MenDeal = true;

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) { _imguiReady = NO; }
    return self;
}

- (void)loadView {
    CGRect frame = UIScreen.mainScreen.bounds;
    MTKView *view = [[MTKView alloc] initWithFrame:frame];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.backgroundColor = UIColor.clearColor;
    view.opaque = NO;
    view.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 0.0);
    view.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
    view.preferredFramesPerSecond = 60;
    view.enableSetNeedsDisplay = NO;
    view.paused = NO;
    view.userInteractionEnabled = YES;
    
    self.view = view;
    self.metalView = view;
    view.delegate = self;

    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    view.device = device;
    self.commandQueue = [device newCommandQueue];

    if (device != nil && self.commandQueue != nil) {
        ImGui::CreateContext();
        ImGuiIO &io = ImGui::GetIO();
        io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;
        io.DisplaySize = ImVec2(frame.size.width, frame.size.height);
        io.DisplayFramebufferScale = ImVec2(UIScreen.mainScreen.scale, UIScreen.mainScreen.scale);

        // Dùng font mặc định để tránh văng do font
        io.Fonts->AddFontDefault();

        ImGui_ImplMetal_Init(device);
        self.imguiReady = YES;
    }
}

+ (void)showChange:(BOOL)open {
    MenDeal = open;
}

+ (BOOL)isMenuShowing {
    return MenDeal;
}

- (void)drawInMTKView:(MTKView *)view {
    if (!self.imguiReady || !MenDeal) return;

    MTLRenderPassDescriptor *pass = view.currentRenderPassDescriptor;
    id<CAMetalDrawable> drawable = view.currentDrawable;
    if (pass == nil || drawable == nil) return;

    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    if (commandBuffer == nil) return;

    ImGui_ImplMetal_NewFrame(pass);
    ImGuiIO &io = ImGui::GetIO();
    io.DisplaySize = ImVec2(view.bounds.size.width, view.bounds.size.height);
    io.DisplayFramebufferScale = ImVec2(view.contentScaleFactor, view.contentScaleFactor);

    ImGui::NewFrame();
    UserMenu::GetInstance().RenderingMenu(); // Vẽ Menu
    ImGui::Render();

    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:pass];
    if (encoder != nil) {
        ImGui_ImplMetal_RenderDrawData(ImGui::GetDrawData(), commandBuffer, encoder);
        [encoder endEncoding];
    }

    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
}

// ==========================================
// XỬ LÝ TOUCH
// ==========================================
- (void)updateIOWithTouchEvent:(UIEvent *)event {
    if (!self.imguiReady) return;
    UITouch *touch = event.allTouches.anyObject;
    if (touch == nil) return;

    CGPoint point = [touch locationInView:self.metalView];
    ImGuiIO &io = ImGui::GetIO();
    io.MousePos = ImVec2(point.x, point.y);

    switch (touch.phase) {
        case UITouchPhaseBegan:
        case UITouchPhaseMoved:
        case UITouchPhaseStationary:
            io.MouseDown[0] = true;
            break;
        case UITouchPhaseEnded:
        case UITouchPhaseCancelled:
            io.MouseDown[0] = false;
            break;
        default: break;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    if (!self.imguiReady) return;
    ImGuiIO &io = ImGui::GetIO();
    io.DisplaySize = ImVec2(size.width / view.contentScaleFactor, size.height / view.contentScaleFactor);
}

- (void)dealloc {
    if (self.imguiReady) {
        ImGui_ImplMetal_Shutdown();
        ImGui::DestroyContext();
        self.imguiReady = NO;
    }
}

// ==========================================
// MẤY CÁI HÀM HOOK CỦA MÀY (Bỏ comment để xài)
// ==========================================
/*
- (void)setupHooks {
    // HOOK(ENCRYPTOFFSET("0x61E0F48"), _cam, cam); 
    // HOOK(ENCRYPTOFFSET("0x61DFF50"), _Update, Update); 
    // HOOK(ENCRYPTOFFSET("0x61E1370"), _highrate, highrate); 
    // HOOK(ENCRYPTOFFSET("0x59EC6F4"), IsSmartUse, _IsSmartUse); 
    // HOOK(ENCRYPTOFFSET("0x57CC0F4"), get_IsUseCameraMoveWithIndicator, _get_IsUseCameraMoveWithIndicator); 
    // HOOK(ENCRYPTOFFSET("0x64C773C"), IsDistanceLowerEqualAsAttacker, old_IsDistanceLowerEqualAsAttacker); 
    // HOOK(ENCRYPTOFFSET("0x5AD7B84"), IsUseSkillJoystick, _IsUseSkillJoystick); 
    // HOOK(ENCRYPTOFFSET("0x5A6A764"), SetPlayerName, old_SetPlayerName); 
    // HOOK(ENCRYPTOFFSET("0x547FB70"), _Autowin, Autowin); 
    // HOOK(ENCRYPTOFFSET("0x53AC920"), LActorRoot_Visible, _LActorRoot_Visible); 
}
*/

@end
