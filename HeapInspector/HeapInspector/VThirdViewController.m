

//
//  VThirdViewController.m
//  HeapInspector
//
//  Created by 蚩尤 on 16/5/27.
//  Copyright © 2016年 ouer. All rights reserved.
//

#import "VThirdViewController.h"

@implementation VThirdViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //造成循环引用
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(time:) userInfo:nil repeats:YES];

}

- (void)time:(NSTimer *)timer {
    
}
@end
