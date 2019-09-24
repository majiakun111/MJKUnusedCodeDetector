//
//  realized-class.m
//  MJKUnuesdCodeDetector
//
//  Created by Ansel on 2019/9/23.
//  Copyright © 2019 Ansel. All rights reserved.
//

#if __LP64__
#import "mjk-realized-class.h"

#import <objc/objc.h>
#import <stdint.h>

#import <dlfcn.h>
#import <mach-o/getsect.h>

struct class_rw_t {
    uint32_t flags;
};

#define FAST_DATA_MASK        0x00007ffffffffff8UL

struct class_data_bits_t {
    // Values are the FAST_ flags above.
    uintptr_t bits;
    
    class_rw_t* data() {
        return (class_rw_t *)(bits & FAST_DATA_MASK);
    }
};

typedef uint32_t mask_t;

struct cache_t {
    struct bucket_t *_buckets;
    mask_t _mask;
    mask_t _occupied;
};


#define RW_REALIZED           (1<<31)

struct objc_class : objc_object {
    // Class ISA;
    Class superclass;
    cache_t cache;             // formerly cache pointer and vtable
    class_data_bits_t bits;    // class_rw_t * plus custom rr/alloc flags
    
    class_rw_t *data() {
        return bits.data();
    }
    
    // Locking: To prevent concurrent realization, hold runtimeLock.
    bool isRealized() {
        return data()->flags & RW_REALIZED;
    }
};

bool isClassRealized(Class cls) {
    return ((__bridge struct objc_class*)cls)->isRealized();
}

int getRealizedClasses(Class *buffer, int bufferLen) {
    Dl_info info;
    dladdr((const void *)&getRealizedClasses, &info);
    
    const uint64_t mach_header = (uint64_t)info.dli_fbase;
    const struct section_64 *section = getsectbynamefromheader_64((const struct mach_header_64 *)mach_header, "__DATA", "__objc_classlist");
    if (section == NULL) {
        return 0;
    }
    
    int count = 0;
    for (uint64_t addr = section->offset; addr < section->offset + section->size; addr += sizeof(const char **)) {
        Class cls = (__bridge Class)(*(void **)(mach_header + addr));
        if (isClassRealized(cls)) {
            if (buffer && (count < bufferLen)) {
                buffer[count] = cls;
            }
            count++;
        }
    }
    
    return count;
}

int getAllClassCount(void) {
    Dl_info info;
    dladdr((const void *)&getAllClassCount, &info);
    
    const uint64_t mach_header = (uint64_t)info.dli_fbase;
    const struct section_64 *section = getsectbynamefromheader_64((const struct mach_header_64 *)mach_header, "__DATA", "__objc_classlist");
    if (section == NULL) {
        return 0;
    }
    
    return (int)(section->size / sizeof(const char **));
}

#endif
