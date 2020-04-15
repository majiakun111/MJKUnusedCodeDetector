//
//  RealizedClassDetector.m
//  MJKUnuesdCodeDetector
//
//  Created by Ansel on 2019/9/23.
//  Copyright © 2019 Ansel. All rights reserved.
//

#if __LP64__

#import "MJKRealizedClassDetector.h"
#import "mjk-realized-class.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

// do nothing, used for checking dirty
@interface MJKRealizedClassDetectorDummy : NSObject
@end

@implementation MJKRealizedClassDetectorDummy
@end

static BOOL g_isRunning = NO;
static NSTimeInterval g_lastReportTime = 0;

@implementation MJKRealizedClassDetector

+ (void)reportRealizedClassAsyncInBackground {
    if (![self shouldReport]) {
        return;
    }
    
    g_isRunning = YES;
    g_lastReportTime = CACurrentMediaTime();
    
    __block UIBackgroundTaskIdentifier bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"MJKRealizedClassDetector" expirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self reportRealizedClass];
        g_isRunning = NO;
        
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    });
}


#pragma mark - PrivateMethod

+ (BOOL)shouldReport {
    if (g_isRunning) {
        return NO;
    }
    
    // 1 分钟内不重复处理
    if (g_lastReportTime != 0 && (CACurrentMediaTime() - g_lastReportTime < 60)) {
        return NO;
    }
    
    return YES;
}

+ (void)reportRealizedClass {
    int allClassCount = getAllClassCount();
    Class *realizedClasses = (Class *)malloc(allClassCount * sizeof(Class));
    int realizedClassCount = getRealizedClasses(realizedClasses, allClassCount);
    
    if (realizedClassCount == 0) {
        free(realizedClasses);
        return;
    }
    
    BOOL dirty = NO;

    NSMutableArray *classNames = [NSMutableArray arrayWithCapacity:realizedClassCount];
    for (int i = 0; i < realizedClassCount; i++) {
        Class cls = realizedClasses[i];
        NSString *name = [NSString stringWithUTF8String:class_getName(cls)];
        
        // 如果 MJKRealizedClassDetectorDummy 这个代码里不使用的类被 realize 了，说明做了类似 objc_copyClassList 会 realize 所有类的事
        if (!dirty && [name isEqualToString:@"MJKRealizedClassDetectorDummy"]) {
            dirty = YES;
        }
        
        [classNames addObject:name];
    }
    free(realizedClasses);

    NSString *classNamesString = [classNames componentsJoinedByString:@","];
   
    NSLog(@"----classNamesString:%@, dirty:%d", classNamesString, dirty);
}

@end

#endif
