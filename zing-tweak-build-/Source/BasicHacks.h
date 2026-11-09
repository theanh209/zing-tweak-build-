// File: Source/BasicHacks.h
#pragma once

#import <Foundation/Foundation.h>
#include <cstdint>
#include <mach-o/dyld.h>

// Include file Includes.h để lấy struct CheatVars và KomaruPatch
#include "../MenuLoad/Includes.h"

// Khai báo Interface cho GameLoop
@interface GameLoop : NSObject
- (void)start;
- (void)stop;
@end

// Khai báo class BasicHacks
class BasicHacks {
public:
    BasicHacks(const BasicHacks&) = delete;

    static BasicHacks& GetInstance() {
        static BasicHacks Instance;
        return Instance;
    }

    static bool IsValidPointer(long Offset);
    static void HacksThread();
    
    void Initialize();

private:
    BasicHacks() { }
};

// Khởi tạo biến instance toàn cục
static BasicHacks& BasicCheats = BasicHacks::GetInstance();