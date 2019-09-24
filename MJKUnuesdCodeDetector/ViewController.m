//
//  ViewController.m
//  MJKUnuesdCodeDetector
//
//  Created by Ansel on 2019/9/24.
//  Copyright © 2019 Ansel. All rights reserved.
//

#import "ViewController.h"
#import "MJKRealizedClassDetector.h"
#import "mjk-realized-class.h"
#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, 200, CGRectGetWidth(self.view.frame) - 40, 100)];
    [button setBackgroundColor:[UIColor redColor]];
    [button setTitle:@"Get Realized Classes" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didClickButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)didClickButton
{
#if __LP64__
    int realizedClassCount = getRealizedClasses(NULL, 0);
    Class *realizedClasses = (Class *)malloc(realizedClassCount * sizeof(Class));
    realizedClassCount = getRealizedClasses(realizedClasses, realizedClassCount);

    NSLog(@"Realized Classes Count: %@", @(realizedClassCount));

    for (int i = 0; i < realizedClassCount; i++) {
        Class cls = realizedClasses[i];
        NSLog(@"%@", [NSString stringWithUTF8String:class_getName(cls)]);
    }
    free(realizedClasses);

    unsigned int count;
    objc_copyClassList(&count);

    NSLog(@"Realized Classes Count: %@", @(getRealizedClasses(NULL, 0)));
    
    [MJKRealizedClassDetector reportRealizedClassAsyncInBackground];
#endif
}


@end
