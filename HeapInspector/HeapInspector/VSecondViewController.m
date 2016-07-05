


//
//  VSecondViewController.m
//  HeapInspector
//
//  Created by 蚩尤 on 16/5/27.
//  Copyright © 2016年 ouer. All rights reserved.
//

#import "BlockView.h"
#import "AFNetworking.h"
#import "VTableViewCell.h"
#import "VThirdViewController.h"
#import "VSecondTableViewCell.h"
#import "VSecondViewController.h"
typedef void(^TestBlock)();
@interface VSecondViewController()
<UITableViewDelegate,UITableViewDataSource>

{
    NSObject *object;
    UITableView *tabView;
    AFHTTPSessionManager *sessionManager;
    
}
@end
@implementation VSecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    tabView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [tabView registerClass:[VTableViewCell class] forCellReuseIdentifier:@"Cell"];
    [tabView registerClass:[VSecondTableViewCell class] forCellReuseIdentifier:@"SecondCell"];

    tabView.delegate = self;
    tabView.dataSource = self;
    [self.view addSubview:tabView];
    
    
   UIButton *btn = [[UIButton alloc] init];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    btn.backgroundColor = [UIColor redColor];
    btn.frame = CGRectMake(0, 0, 100, 100);
    btn.center = self.view.center;
    //1 会造成循环引用，dealloc不执行
//    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(time:) userInfo:nil repeats:YES];

    
    //2 会造成循环引用因为self->_view->blockView->block->self(->代表持有),dealloc不执行
    __weak typeof(self) wSelf = self;
   BlockView *blockView = [[BlockView alloc] init];
    [self.view addSubview:blockView];
    blockView.block = ^(){
        NSLog(@"eeee %@",blockView);
        [self test];
        object = [[NSObject alloc] init];

//        //要解决循环引用,上面的代码应该这么写。
//        __strong typeof(wSelf) sSelf = wSelf;
//        [wSelf test];
//        sSelf->object = [[NSObject alloc] init];
    };
    
    blockView.block();
    //3 不会造成循环引用, testBlock->self 但是self没有持有testBlock
    TestBlock testBlock = ^(){
        NSLog(@"11111 %@",testBlock);
        [self test];
        object = [[NSObject alloc] init];
        NSLog(@"11111 %@",testBlock);
    };
    testBlock();
    //4 没有造成循环引用 因为success以及failure这两个block，并没有被sessionManager直接或间接持有，它们两个相当于临时变量。所以没有造成循环引用
     sessionManager = [AFHTTPSessionManager manager];
    [sessionManager GET:@"" parameters:@"" progress:NULL success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self test];
        object = [[NSObject alloc] init];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        [self test];
        object = [[NSObject alloc] init];

    }];
    //5 没有造成循环引用(dispatch_async这个block并没有被self持有，所以不存在循环引用，dealloc执行)
    dispatch_async(dispatch_get_main_queue(), ^{
        [self test];
        object = [[NSObject alloc] init];
    });
    /** 重点:
     *  单就block而言:是否造成内存泄露的根本原因，在于是否造成循环引用。如果不构成循环，那么就不存在内存泄漏.
     */
    
    [self getSubImage:5];
    
}


- (UIImage*)getSubImage:(unsigned long)ulUserHeader
 {
        UIImage * sourceImage = [UIImage imageNamed:@"1.png"];
         CGFloat height = sourceImage.size.height;
         CGRect rect = CGRectMake(0 + ulUserHeader*height, 0, height, height);
    
         CGImageRef imageRef = CGImageCreateWithImageInRect([sourceImage CGImage], rect);
         UIImage* smallImage = [UIImage imageWithCGImage:imageRef];
         //CGImageRelease(imageRef)
         return smallImage;
 }
-(void)test {
    
}

-(void)dealloc
{
    NSLog(@"%@ dealloc",self);
    
}
- (void)time:(NSTimer *)time {
}


- (void)btnClick {
    
    VThirdViewController *vc = [[VThirdViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1000;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row %2 == 1) {
        VTableViewCell *cell = [tabView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.textLabel.text = [NSString stringWithFormat:@"Cell %ld",(long)indexPath.row];
        return cell;
    } else {
        VSecondTableViewCell *cell = [tabView dequeueReusableCellWithIdentifier:@"SecondCell" forIndexPath:indexPath];
        cell.textLabel.text = [NSString stringWithFormat:@"SecondCell %ld",(long)indexPath.row];
        return cell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self dismissViewControllerAnimated:YES completion:NULL];
//    VSecondViewController *secondVC = [[VSecondViewController alloc] init];
//    [self presentViewController:secondVC animated:YES completion:NULL];
}



@end
