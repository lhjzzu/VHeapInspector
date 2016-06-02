//
//  ViewController.m
//  HeapInspector
//
//  Created by 蚩尤 on 16/5/26.
//  Copyright © 2016年 ouer. All rights reserved.
//

#import "ViewController.h"
#import "VSecondViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *btn = [[UIButton alloc] init];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    btn.backgroundColor = [UIColor redColor];
    btn.frame = CGRectMake(0, 0, 100, 100);
    btn.center = self.view.center;
}

- (void)btnClick {
    VSecondViewController *vc = [[VSecondViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:navi animated:YES completion:NULL];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
