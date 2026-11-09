#pragma once
#include <stdint.h>
#include <string.h>
#include <mach/mach.h>
#include <sys/mman.h>

class KomaruPatch {
public:
    static bool IsValidPointer(uintptr_t address) {
        // Kiểm tra cơ bản: Địa chỉ phải nằm trong vùng nhớ của app (lớn hơn 0x100000000)
        return address > 0x100000000 && address < 0x3000000000;
    }

    template <typename T>
    static T ReadMem(uintptr_t address) {
        if (!IsValidPointer(address)) return T();
        return *reinterpret_cast<T*>(address);
    }

    template <typename T>
    static bool WriteMem(uintptr_t address, const T& value) {
        if (!IsValidPointer(address)) return false;

        // Lấy kích thước của trang bộ nhớ (thường là 4096 byte)
        uintptr_t pageSize = 4096;
        uintptr_t pageStart = address & ~(pageSize - 1);

        // Bẻ khóa vùng nhớ để cho phép ghi (Read/Write/Execute)
        vm_protect(mach_task_self(), pageStart, pageSize, false, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);

        // Tiến hành ghi đè giá trị
        *reinterpret_cast<T*>(address) = value;
        
        return true;
    }
};
