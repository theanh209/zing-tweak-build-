// MenuLoad/ImGuiDrawView.mm
#import "ImGuiDrawView.h"

#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <QuartzCore/QuartzCore.h>

// SỬA LẠI ĐƯỜNG DẪN Ở ĐÂY
#include "../ImGui/imgui.h"
#include "../ImGui/imgui_impl_metal.h"
#include "UserMenu.h"

@interface ImGuiDrawView () <MTKViewDelegate>
@property (nonatomic, strong) MTKView *metalView;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, assign) BOOL imguiReady;
@property (nonatomic, assign) BOOL menuVisible;
@end

@implementation ImGuiDrawView

static __weak ImGuiDrawView *s_activeView = nil;

- (instancetype)init {
    self = [super init];
    if (self) {
        _menuVisible = YES;
    }
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
    view.depthStencilPixelFormat = MTLPixelFormatInvalid;
    view.preferredFramesPerSecond = 60;
    view.enableSetNeedsDisplay = NO;
    view.paused = NO;
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

        ImGui::StyleColorsDark();
        ImGuiStyle &style = ImGui::GetStyle();
        style.WindowRounding = 8.0f;
        style.FrameRounding = 4.0f;

        ImGui_ImplMetal_Init(device);
        self.imguiReady = YES;
        s_activeView = self;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!self.imguiReady) return;

    CGSize size = self.metalView.bounds.size;
    ImGuiIO &io = ImGui::GetIO();
    io.DisplaySize = ImVec2(size.width, size.height);
    io.DisplayFramebufferScale = ImVec2(self.metalView.contentScaleFactor, self.metalView.contentScaleFactor);
}

- (void)drawInMTKView:(MTKView *)view {
    if (!self.imguiReady || !self.menuVisible) return;

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
    UserMenu::GetInstance().RenderingMenu();
    ImGui::Render();

    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:pass];
    if (encoder != nil) {
        ImGui_ImplMetal_RenderDrawData(ImGui::GetDrawData(), commandBuffer, encoder);
        [encoder endEncoding];
    }

    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    if (!self.imguiReady) return;
    ImGuiIO &io = ImGui::GetIO();
    io.DisplaySize = ImVec2(size.width / view.contentScaleFactor, size.height / view.contentScaleFactor);
}

+ (void)showChange:(BOOL)open {
    dispatch_async(dispatch_get_main_queue(), ^{
        ImGuiDrawView *view = s_activeView;
        if (view == nil) return;
        view.menuVisible = open;
        view.view.hidden = !open;
        view.metalView.paused = !open;
    });
}

+ (BOOL)isMenuShowing {
    ImGuiDrawView *view = s_activeView;
    return (view != nil && view.menuVisible && !view.view.hidden);
}

// PHẦN NHẬN TOUCH (BẮT BUỘC ĐỂ BẤM NÚT)
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
        default:
            break;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }

- (void)dealloc {
    if (self.imguiReady) {
        ImGui_ImplMetal_Shutdown();
        ImGui::DestroyContext();
        self.imguiReady = NO;
    }
    if (s_activeView == self) s_activeView = nil;
}

@end
