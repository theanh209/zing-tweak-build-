// File: Source/BasicHacks.mm 
#import "BasicHacks.h"
#include "../MenuLoad/Includes.h"
#include <chrono>
#include <thread>

// =====================================================================
// KHU VỰC ĐIỀN OFFSET
// =====================================================================
namespace offsets {
    constexpr uintptr_t OFFSET_GWorld                   = 0x0000000; 
    constexpr uintptr_t OFFSET_OwningGameInstance       = 0x0000000; 
    constexpr uintptr_t OFFSET_LocalPlayers             = 0x0000000; 
    constexpr uintptr_t OFFSET_LocalPlayerController    = 0x0000000; 
    constexpr uintptr_t OFFSET_Kart                     = 0x0000000; 

    constexpr uintptr_t OFFSET_VoHanNitro               = 0x0000000; 
    constexpr uintptr_t OFFSET_GiaToc                   = 0x0000000; 
    constexpr uintptr_t OFFSET_HP                       = 0x0000000; 
}
// =====================================================================

// BẮT BUỘC PHẢI CÓ DÒNG NÀY
CheatVars Cheats; 

void BasicHacks::HacksThread() {
    using namespace offsets;

    static uintptr_t BaseAddr = (uintptr_t)_dyld_get_image_header(0);
    static uintptr_t GWorld = 0;

    if (!BaseAddr) return;

    if (GWorld == 0) {
        GWorld = KomaruPatch::ReadMem<uintptr_t>(BaseAddr + OFFSET_GWorld);
    }
    if(!GWorld) return;

    uintptr_t OwningGameInstance = KomaruPatch::ReadMem<uintptr_t>(GWorld + OFFSET_OwningGameInstance);
    if(!OwningGameInstance) return;

    uintptr_t LocalPlayers = KomaruPatch::ReadMem<uintptr_t>(OwningGameInstance + OFFSET_LocalPlayers);
    if(!LocalPlayers) return;

    uintptr_t LocalPlayer = KomaruPatch::ReadMem<uintptr_t>(LocalPlayers);
    if(!LocalPlayer) return;

    uintptr_t LocalPlayerController = KomaruPatch::ReadMem<uintptr_t>(LocalPlayer + OFFSET_LocalPlayerController);
    if(!LocalPlayerController) return;

    uintptr_t Kart = KomaruPatch::ReadMem<uintptr_t>(LocalPlayerController + OFFSET_Kart);
    if(!Kart) return;

    if (Cheats.VoHanNitro) {
        KomaruPatch::WriteMem<float>(Kart + OFFSET_VoHanNitro, 999.0f); 
    }
    if (Cheats.GiaToc) {
        KomaruPatch::WriteMem<float>(Kart + OFFSET_GiaToc, 200.0f);
    }
    if (Cheats.KySinh) {
        KomaruPatch::WriteMem<float>(Kart + OFFSET_HP, 100.0f); 
    }
}

@implementation GameLoop {
    dispatch_source_t _timer;
}

- (void)start {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (_timer) {
        NSTimeInterval interval = 1.0 / 30.0;
        dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), (uint64_t)(interval * NSEC_PER_SEC), 0);
        dispatch_source_set_event_handler(_timer, ^{ BasicHacks::HacksThread(); });
        dispatch_resume(_timer);
    }
}

- (void)stop {
    if (_timer) { dispatch_source_cancel(_timer); }
}
@end

void BasicHacks::Initialize(){
    static GameLoop *gameLoop = [[GameLoop alloc] init];
    [gameLoop start];
}