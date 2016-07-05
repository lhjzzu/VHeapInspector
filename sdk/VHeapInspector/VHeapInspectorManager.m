//
//  VHeapInspectorManager.m
//  HeapInspector
//
//  Created by 蚩尤 on 16/5/30.
//  Copyright © 2016年 ouer. All rights reserved.
//

#ifdef DEBUG
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "VHeapInspectorManager.h"
/**
 *  在控制器pop或dimiss后的多长时间后检查控制器是否释放
 */
#define CheckTimeAfterPopOrDismiss 1.2

static inline void SwizzleInstanceMethod(Class c, SEL origSEL, SEL newSEL)
{
    Method origMethod = class_getInstanceMethod(c, origSEL);
    Method newMethod = class_getInstanceMethod(c, newSEL);
    
    if (class_addMethod(c, origSEL, method_getImplementation(newMethod), method_getTypeEncoding(origMethod))) {
        class_replaceMethod(c, newSEL, method_getImplementation(origMethod), method_getTypeEncoding(newMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

@implementation UIViewController (VHeapInspectorManager)
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SwizzleInstanceMethod([self class], @selector(presentViewController:animated:completion:), @selector(v_presentViewController:animated:completion:));
        SwizzleInstanceMethod([self class], @selector(dismissViewControllerAnimated:completion:), @selector(v_dismissViewControllerAnimated:completion:));
        SwizzleInstanceMethod([self class], NSSelectorFromString(@"dealloc"), @selector(v_dealloc));
    });
}


- (void)v_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    NSString *vcInfo = [NSString stringWithFormat:@"%@: %p",[viewControllerToPresent class],viewControllerToPresent];
    if (![viewControllerToPresent isKindOfClass:[UIAlertController class]]) {
        [[VHeapInspectorManager manager] recordWithViewController:vcInfo];
    }
//    NSLog(@"presentViewController == %@",vcInfo);
    [self v_presentViewController:viewControllerToPresent animated:flag completion:completion];
}
- (void)v_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (![self isKindOfClass:NSClassFromString(@"UIApplicationRotationFollowingController")] && ![self isKindOfClass:NSClassFromString(@"_UIAlertShimPresentingViewController")]) {
        [VHeapInspectorManager manager].currentBackVCInfo = [NSString stringWithFormat:@"%@: %p",[self class],self];
        [[VHeapInspectorManager manager] performSelector:@selector(checkIsDeallocOfVc) withObject:nil afterDelay:CheckTimeAfterPopOrDismiss];
//        NSLog(@"dismissViewController == %@",[VHeapInspectorManager manager].currentBackVCInfo);
    }
#pragma clang diagnostic pop
    [self v_dismissViewControllerAnimated:flag completion:completion];
}


- (void)v_dealloc {
    NSString *vcInfo = [NSString stringWithFormat:@"%@: %p",[self class],self];
    [[VHeapInspectorManager manager] removeWithViewController:vcInfo];
//    NSLog(@"v_dealloc %@ 释放",vcInfo);
    [self v_dealloc];
}
@end

@implementation UINavigationController (VHeapInspectorManager)
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SwizzleInstanceMethod([self class], @selector(pushViewController:animated:), @selector(v_pushViewController:animated:));
        SwizzleInstanceMethod([self class], @selector(popViewControllerAnimated:), @selector(v_popViewControllerAnimated:));
        SwizzleInstanceMethod([self class], @selector(popToRootViewControllerAnimated:), @selector(v_popToRootViewControllerAnimated:));
        SwizzleInstanceMethod([self class], @selector(popToViewController:animated:), @selector(v_popToViewController:animated:));
    });
}
- (void)v_pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSString *vcInfo  = [NSString stringWithFormat:@"%@: %p",[viewController class],viewController];
    [[VHeapInspectorManager manager] recordWithViewController:vcInfo];
    [self v_pushViewController:viewController animated:animated];
}

- (UIViewController *)v_popViewControllerAnimated:(BOOL)animated
{
    UIViewController *vc = [self v_popViewControllerAnimated:animated];
    [VHeapInspectorManager manager].currentBackVCInfo = [NSString stringWithFormat:@"%@: %p",[vc class],vc];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [[VHeapInspectorManager manager] performSelector:@selector(checkIsDeallocOfVc) withObject:nil afterDelay:CheckTimeAfterPopOrDismiss];
#pragma clang diagnostic pop
    return vc;
}

- (NSArray<UIViewController *> *)v_popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    UIViewController *vc = [self.viewControllers lastObject];
    NSArray<UIViewController *> *arr = [self v_popToViewController:viewController animated:animated];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [VHeapInspectorManager manager].currentBackVCInfo = [NSString stringWithFormat:@"%@: %p",[vc class],vc];
    [[VHeapInspectorManager manager] performSelector:@selector(checkIsDeallocOfVc) withObject:nil afterDelay:CheckTimeAfterPopOrDismiss];
#pragma clang diagnostic pop

    return arr;
}

- (NSArray<UIViewController *> *)v_popToRootViewControllerAnimated:(BOOL)animated
{
    UIViewController *vc = [self.viewControllers lastObject];
    NSArray<UIViewController *> *arr = [self v_popToRootViewControllerAnimated:animated];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [VHeapInspectorManager manager].currentBackVCInfo = [NSString stringWithFormat:@"%@: %p",[vc class],vc];
    [[VHeapInspectorManager manager] performSelector:@selector(checkIsDeallocOfVc) withObject:nil afterDelay:CheckTimeAfterPopOrDismiss];
#pragma clang diagnostic pop
    return arr;
}
@end


static VHeapInspectorManager *manager;
static NSMutableSet *recordedVCSet;
static NSArray *ignoreVCArr;
@implementation VHeapInspectorManager
+ (instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[VHeapInspectorManager alloc] init];
    });
    return manager;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        //忽略的控制器数组
        ignoreVCArr = @[@"xxx"];//例如:VSecondViewController
    }
    return self;
}

- (NSMutableSet *)recordWithViewController:(NSString *)vcInfo
{
    NSRange range = [vcInfo rangeOfString:@" "];
    NSString *className = [vcInfo substringWithRange:NSMakeRange(0, range.location-1)];
    if ([ignoreVCArr containsObject:className]) {
        return recordedVCSet;
    }
    if (!recordedVCSet) {
        recordedVCSet = [NSMutableSet setWithObject:vcInfo];
    } else {
        [recordedVCSet addObject:vcInfo];
    }
    return recordedVCSet;
}

- (NSMutableSet *)removeWithViewController:(NSString *)vcInfo
{
    if (recordedVCSet.count > 0) {
        if ([recordedVCSet containsObject:vcInfo]) {
            [recordedVCSet removeObject:vcInfo];
        }
    }
    return recordedVCSet;
}
/** 判断该控制器是否已经释放
 
 *  注意:两种情况下会误报(该控制器实际上能释放)
 *  1 checkIsDeallocOfVc(判断函数)在v_dealloc(释放函数)前执行(打断点，或执行耗时任务)
 *  2 频繁的进入退出某个控制器:因为该控制器能释放，所以频繁进出该控制器时，有可能相邻两次控制器的内存地址是一致的。如果第二次进入后，第一次的判断才执行，那么就会造成误报。
 */
- (void)checkIsDeallocOfVc {
//    NSLog(@"recordedVCSet == %@",recordedVCSet);
//    NSLog(@"checkIsDeallocOfVc == %@",self.currentBackVCInfo);
    if ([recordedVCSet containsObject:self.currentBackVCInfo]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSString *copyInfo = [self.currentBackVCInfo copy];
        NSString *info = [NSString stringWithFormat:@"%@可能未释放",copyInfo];
        info = [info stringByReplacingOccurrencesOfString:@"(" withString:@""];
        info = [info stringByReplacingOccurrencesOfString:@")" withString:@""];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告" message:info delegate:[VHeapInspectorManager manager] cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
#pragma clang diagnostic pop
    }
    
}

@end
#endif