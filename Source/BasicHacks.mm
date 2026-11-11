// File: Source/BasicHacks.mm 
#import "BasicHacks.h"
#include "../MenuLoad/Includes.h"
#include "../utils/KPatch.hpp" 
#include <chrono>
#include <thread>
#include <cmath>
#include <mach-o/dyld.h>
#include <string.h>

namespace offsets {
    // Để 0x0, không đọc bộ nhớ khi chưa có offset
    constexpr uintptr_t OFFSET_GWorld                   = 0x0000000; 
    constexpr uintptr_t OFFSET_OwningGameInstance       = 0x0000000; 
    constexpr uintptr_t OFFSET_LocalPlayers             = 0x0000000; 
    constexpr uintptr_t OFFSET_LocalPlayerController    = 0x0000000; 
    constexpr uintptr_t OFFSET_Kart                     = 0x0000000; 
    constexpr uintptr_t OFFSET_VoHanNitro               = 0x0000000; 
    constexpr uintptr_t OFFSET_GiaToc                   = 0x0000000; 
    constexpr uintptr_t OFFSET_HP                       = 0x0000000; 
    constexpr uintptr_t OFFSET_Kart_Position            = 0x0000000; 
    constexpr uintptr_t OFFSET_Kart_Yaw                 = 0x0000000; 
}

struct Vec3 { float x, y, z; };
CheatVars Cheats; 

uintptr_t GetUnityBase() {
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        if (name && strstr(name, "UnityFramework")) {
            return _dyld_get_image_vmaddr_slide(i);
        }
    }
    return 0;
}

static float CalcTargetYaw(const Vec3& from, const Vec3& to) {
    return atan2f(to.x - from.x, to.z - from.z) * (180.0f / 3.14159265f);
}
static float NormalizeAngle(float ang) {
    while (ang > 180.0f) ang -= 360.0f;
    while (ang < -180.0f) ang += 360.0f;
    return ang;
}

void BasicHacks::HacksThread() {
    using namespace offsets;

    // CHẶN VĂNG: Nếu chưa có offset thì dừng luôn
    if (OFFSET_GWorld == 0) return; 

    static uintptr_t BaseAddr = GetUnityBase();
    if (!BaseAddr) return;

    static uintptr_t GWorld = 0;
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

    if (Cheats.VoHanNitro && OFFSET_VoHanNitro != 0) {
        KomaruPatch::WriteMem<float>(Kart + OFFSET_VoHanNitro, 3.0f); 
    }
    if (Cheats.GiaToc && OFFSET_GiaToc != 0) {
        KomaruPatch::WriteMem<float>(Kart + OFFSET_GiaToc, 105.0f);
    }
    if (Cheats.KySinh && OFFSET_HP != 0) {
        KomaruPatch::WriteMem<float>(Kart + OFFSET_HP, 100.0f); 
    }

    if (Cheats.AutoDuaLapTrinh && OFFSET_Kart_Position != 0 && OFFSET_Kart_Yaw != 0) {
        Vec3 pos = KomaruPatch::ReadMem<Vec3>(Kart + OFFSET_Kart_Position);
        float current_yaw = KomaruPatch::ReadMem<float>(Kart + OFFSET_Kart_Yaw);
        static Vec3 target_waypoint = { 100.0f, 0.0f, 200.0f }; 
        
        if (pos.x != 0.0f || pos.y != 0.0f) {
            float target_yaw = CalcTargetYaw(pos, target_waypoint);
            float delta_yaw = NormalizeAngle(target_yaw - current_yaw);
            if (Cheats.AutoMode == 1) {
                KomaruPatch::WriteMem<float>(Kart + OFFSET_Kart_Yaw, current_yaw + (delta_yaw * 0.15f));
            } else if (Cheats.AutoMode == 2) {
                KomaruPatch::WriteMem<float>(Kart + OFFSET_Kart_Yaw, current_yaw + (delta_yaw * 0.45f));
            }
        }
    }
}

@implementation GameLoop {
    dispatch_source_t _timer;
}
- (void)start {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (_timer) {
        NSTimeInterval interval = 1.0 / 60.0; 
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
