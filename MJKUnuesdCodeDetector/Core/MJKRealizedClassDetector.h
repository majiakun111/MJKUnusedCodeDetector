//
//  RealizedClassDetector.h
//  MJKUnuesdCodeDetector
//
//  Created by Ansel on 2019/9/23.
//  Copyright © 2019 Ansel. All rights reserved.
//

#if __LP64__

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MJKRealizedClassDetector : NSObject

// call this method on applicationDidEnterBackground with `#if __LP64__`
+ (void)reportRealizedClassAsyncInBackground;

@end

NS_ASSUME_NONNULL_END

#endif
