// File: MenuLoad/ImGuiDrawView.mm
#import "ImGuiDrawView.h"
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <QuartzCore/QuartzCore.h>

#include "../ImGui/imgui.h"
#include "../ImGui/imgui_impl_metal.h"
#include "UserMenu.h"

@interface ImGuiDrawView () <MTKViewDelegate>
@property (nonatomic, strong) MTKView *metalView;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, assign) BOOL imguiReady;
@end

@implementation ImGuiDrawView

// Biến toàn cục để lưu vị trí chạm cuối cùng (dùng cho vuốt)
static CGPoint s_lastTouchPos = {0, 0};
static CFTimeInterval s_lastTouchTime = 0;

- (instancetype)init {
    self = [super init];
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
    
    // Bật tương tác để nhận vuốt
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

        // Dùng font mặc định để tránh lỗi
        io.Fonts->AddFontDefault();

        ImGui_ImplMetal_Init(device);
        self.imguiReady = YES;
    }
}

- (void)drawInMTKView:(MTKView *)view {
    if (!self.imguiReady) return;

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
    UserMenu::GetInstance().RenderingMenu(); // Gọi hàm vẽ Menu
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
// XỬ LÝ VUỐT (Bật/tắt Menu thay cho nút bấm)
// ==========================================
- (void)updateIOWithTouchEvent:(UIEvent *)event {
    if (!self.imguiReady) return;
    UITouch *touch = event.allTouches.anyObject;
    if (touch == nil) return;

    CGPoint point = [touch locationInView:self.metalView];
    
    // Cập nhật vị trí chuột cho ImGui
    ImGuiIO &io = ImGui::GetIO();
    io.MousePos = ImVec2(point.x, point.y);

    if (touch.phase == UITouchPhaseBegan) {
        s_lastTouchPos = point;
        s_lastTouchTime = CACurrentMediaTime();
    } 
    else if (touch.phase == UITouchPhaseEnded) {
        CFTimeInterval duration = CACurrentMediaTime() - s_lastTouchTime;
        CGFloat deltaX = point.x - s_lastTouchPos.x;
        CGFloat deltaY = point.y - s_lastTouchPos.y;
        
        // Vuốt từ mép trái sang phải (Mở Menu)
        if (s_lastTouchPos.x < 40 && deltaX > 100 && fabs(deltaY) < 50) {
            UserMenu::GetInstance().isMenuOpen = true;
        }
        // Vuốt từ mép phải sang trái (Đóng Menu)
        else if (s_lastTouchPos.x > SCREEN_WIDTH - 40 && deltaX < -100 && fabs(deltaY) < 50) {
            UserMenu::GetInstance().isMenuOpen = false;
        }
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

@end
