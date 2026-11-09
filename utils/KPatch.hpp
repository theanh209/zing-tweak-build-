#pragma once
#include <mach/mach.h>
#include <cstring>
#include <sys/sysctl.h>

class KomaruPatch {
public:
    static bool IsValidPointer(uintptr_t address) {
        if (address == 0) return false;
        vm_address_t region_address = (vm_address_t)address;
        vm_size_t region_size = 0;
        vm_region_basic_info_data_t info;
        mach_msg_type_number_t info_count = VM_REGION_BASIC_INFO_COUNT;
        mach_port_t object_name;
        kern_return_t kr = vm_region(mach_task_self(), &region_address, &region_size, VM_REGION_BASIC_INFO, (vm_region_info_t)&info, &info_count, &object_name);
        if (kr != KERN_SUCCESS) return false;
        return address >= region_address && address < (region_address + region_size);
    }

    template <typename T>
    static T ReadMem(uintptr_t address) {
        if (!IsValidPointer(address)) return T();
        T value = {};
        vm_size_t size = sizeof(T);
        kern_return_t kr = vm_read_overwrite(mach_task_self(), address, size, (vm_address_t)&value, &size);
        if (kr != KERN_SUCCESS || size != sizeof(T)) return T();
        return value;
    }

    template <typename T>
    static bool WriteMem(uintptr_t address, const T& value) {
        if (!IsValidPointer(address)) return false;
        vm_prot_t currentProtection;
        vm_address_t region_address = (vm_address_t)address;
        vm_size_t region_size = 0;
        vm_region_basic_info_data_t info;
        mach_msg_type_number_t info_count = VM_REGION_BASIC_INFO_COUNT;
        mach_port_t object_name;

        kern_return_t kr = vm_region(mach_task_self(), &region_address, &region_size, VM_REGION_BASIC_INFO, (vm_region_info_t)&info, &info_count, &object_name);

        if (kr != KERN_SUCCESS || !(info.protection & VM_PROT_WRITE)) {
            kr = vm_protect(mach_task_self(), address, sizeof(T), false, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
            if (kr != KERN_SUCCESS) return false;
        }

        memcpy((void*)address, &value, sizeof(T));
        return true;
    }
};
