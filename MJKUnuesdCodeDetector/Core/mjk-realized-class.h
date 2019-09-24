//
//  realized-class.h
//  MJKUnuesdCodeDetector
//
//  Created by Ansel on 2019/9/23.
//  Copyright © 2019 Ansel. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __LP64__ // x86_64 & arm64 only!

#ifdef __cplusplus
extern "C" {
#endif /// __cplusplus
    bool isClassRealized(Class cls);

    // return realized class count, even buffer = NULL or bufferLen = 0
    int getRealizedClasses(Class *buffer, int bufferLen);
    
    int getAllClassCount(void);
#ifdef __cplusplus
}
#endif /// __cplusplus

#endif /// __LP64__
