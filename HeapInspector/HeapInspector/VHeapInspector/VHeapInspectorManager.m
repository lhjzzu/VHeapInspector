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
#import "VHeapStackInspector.h"

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

@implementation UITableViewCell (VHeapInspectorManager)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SwizzleInstanceMethod([self class], @selector(initWithStyle:reuseIdentifier:), @selector(tw_initWithStyle:reuseIdentifier:));
    });
}
- (instancetype)tw_initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    UITableViewCell *cell = [self tw_initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    NSString *cellInfo = [NSString stringWithFormat:@"%@: %p",[cell class], cell];
    
    NSArray *recordedVCArr = [[VHeapInspectorManager manager] getRecordedVCArr];
    NSDictionary *recordedHeapDic = [[VHeapInspectorManager manager] getRecordedHeapDic];
    NSMutableSet *set = [recordedHeapDic objectForKey:[recordedVCArr lastObject]];
    [set addObject:cellInfo];
    return cell;
}
@end

@implementation UICollectionViewCell (VHeapInspectorManager)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SwizzleInstanceMethod([self class], @selector(initWithFrame:), @selector(tw_initWithFrame:));
    });
}
- (instancetype)tw_initWithFrame:(CGRect)frame
{
    UICollectionViewCell *cell = [self tw_initWithFrame:frame];
    NSString *cellInfo = [NSString stringWithFormat:@"%@: %p",[cell class], cell];
    NSArray *recordedVCArr = [[VHeapInspectorManager manager] getRecordedVCArr];
    NSDictionary *recordedHeapDic = [[VHeapInspectorManager manager] getRecordedHeapDic];
    NSMutableSet *set = [recordedHeapDic objectForKey:[recordedVCArr lastObject]];
    [set addObject:cellInfo];
    return cell;
}

@end

@implementation UIViewController (VHeapInspectorManager)
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SwizzleInstanceMethod([self class], @selector(presentViewController:animated:completion:), @selector(tw_presentViewController:animated:completion:));
        SwizzleInstanceMethod([self class], @selector(dismissViewControllerAnimated:completion:), @selector(tw_dismissViewControllerAnimated:completion:));
    });
}

- (void)tw_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    NSString *vcInfo = nil;
    if ([viewControllerToPresent isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navi = (UINavigationController *)viewControllerToPresent;
        UIViewController *vc = [navi.viewControllers firstObject];
        vcInfo = [NSString stringWithFormat:@"%@: %p",[vc class],vc];
    } else {
        vcInfo = [NSString stringWithFormat:@"%@: %p",[viewControllerToPresent class],viewControllerToPresent];
    }
    [[VHeapInspectorManager manager] recordWithViewController:vcInfo];
    NSSet *mutableSet = [NSMutableSet set];
    [[VHeapInspectorManager manager] recordedHeapDicWithRecordedHeap:mutableSet withVCInfo:vcInfo];
    [self tw_presentViewController:viewControllerToPresent animated:flag completion:completion];
}
- (void)tw_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (![self isKindOfClass:NSClassFromString(@"UIApplicationRotationFollowingController")]) {
        [[VHeapInspectorManager manager] performSelector:@selector(checkIsDeallocOfVc) withObject:nil afterDelay:1];
        NSLog(@"class == %@",[self class]);
    }
#pragma clang diagnostic pop
    [self tw_dismissViewControllerAnimated:flag completion:completion];
    
}
@end

@implementation UINavigationController (VHeapInspectorManager)
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SwizzleInstanceMethod([self class], @selector(pushViewController:animated:), @selector(tw_pushViewController:animated:));
        SwizzleInstanceMethod([self class], @selector(popViewControllerAnimated:), @selector(tw_popViewControllerAnimated:));
        SwizzleInstanceMethod([self class], @selector(popToRootViewControllerAnimated:), @selector(tw_popToRootViewControllerAnimated:));
        SwizzleInstanceMethod([self class], @selector(popToViewController:animated:), @selector(tw_popToViewController:animated:));
    });
}
- (void)tw_pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSString *vcInfo = nil;
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navi = (UINavigationController *)viewController;
        UIViewController *vc = [navi.viewControllers firstObject];
        vcInfo = [NSString stringWithFormat:@"%@: %p",[vc class],vc];
    } else {
        vcInfo = [NSString stringWithFormat:@"%@: %p",[viewController class],viewController];
    }
    [[VHeapInspectorManager manager] recordWithViewController:vcInfo];
    NSSet *mutableSet = [NSMutableSet set];
    [[VHeapInspectorManager manager] recordedHeapDicWithRecordedHeap:mutableSet withVCInfo:vcInfo];
    
    [self tw_pushViewController:viewController animated:animated];
}

- (UIViewController *)tw_popViewControllerAnimated:(BOOL)animated
{
    
    
    UIViewController *vc = [self tw_popViewControllerAnimated:animated];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [[VHeapInspectorManager manager] performSelector:@selector(checkIsDeallocOfVc) withObject:nil afterDelay:1];
#pragma clang diagnostic pop
    return vc;
}

- (NSArray<UIViewController *> *)tw_popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSArray<UIViewController *> *arr = [self tw_popToViewController:viewController animated:animated];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [[VHeapInspectorManager manager] performSelector:@selector(checkIsDeallocOfVc) withObject:nil afterDelay:1];
#pragma clang diagnostic pop
    return arr;
}

- (NSArray<UIViewController *> *)tw_popToRootViewControllerAnimated:(BOOL)animated
{
    NSArray<UIViewController *> *arr = [self tw_popToRootViewControllerAnimated:animated];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [[VHeapInspectorManager manager] performSelector:@selector(checkIsDeallocOfVc) withObject:nil afterDelay:1];
#pragma clang diagnostic pop
    return arr;
}
@end


static VHeapInspectorManager *manager;
static NSMutableArray *unreleaseObjArr;
static NSMutableArray *recordedVCArr;
static NSMutableDictionary *recordedHeapDic;

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
        [VHeapStackInspector addClassPrefixesToRecord:@[@"V"]];
        [VHeapStackInspector ignoreClassNamesToRecord:@[@"VHeapInspectorManager"]];
    }
    return self;
}

- (NSSet *)heap {
    return [VHeapStackInspector heap];
}

- (NSArray *)recordWithViewController:(NSString *)vcInfo
{
    if (!recordedVCArr) {
        recordedVCArr = [NSMutableArray arrayWithObject:vcInfo];
    } else {
        [recordedVCArr addObject:vcInfo];
    }
    return recordedVCArr;
}

- (NSArray *)getRecordedVCArr {
    return recordedVCArr;
}
- (NSArray *)getunreleaseObjArr {
    return unreleaseObjArr;
}
- (NSDictionary *)getRecordedHeapDic {
    return recordedHeapDic;
}
- (void)checkIsDeallocOfVc {
    __block   NSString *last = [recordedVCArr lastObject];
    dispatch_queue_t queue = dispatch_queue_create([last UTF8String], DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        unreleaseObjArr = [NSMutableArray array];
        
        [recordedVCArr removeLastObject];
        __block NSSet *set = [self heap];
        BOOL vcRelease = YES;
        if ([set containsObject:last]) {
            vcRelease = NO;
            [unreleaseObjArr addObject:last];
        }
        __block BOOL elementRelease = YES;
        NSSet *recordedHeap = [recordedHeapDic objectForKey:last];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [recordedHeapDic removeObjectForKey:last];
            [recordedHeap enumerateObjectsUsingBlock:^(NSString *info, BOOL * _Nonnull stop) {
                if ([set containsObject:info]) {
                    elementRelease = NO;
                    NSLog(@"%@ 未释放",info);
                    [unreleaseObjArr addObject:info];
                }
            }];
            if (vcRelease == NO || elementRelease == NO) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                NSString *info = [NSString stringWithFormat:@"%@未释放",unreleaseObjArr];
                info = [info stringByReplacingOccurrencesOfString:@"(" withString:@""];
                info = [info stringByReplacingOccurrencesOfString:@")" withString:@""];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告" message:info delegate:[VHeapInspectorManager manager] cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alertView show];
#pragma clang diagnostic pop
                
            }
        });
        
    });
}
- (NSMutableDictionary *)recordedHeapDicWithRecordedHeap:(NSSet *)recordedHeap withVCInfo:(NSString *)vcInfo {
    if (!recordedHeapDic) {
        recordedHeapDic = [NSMutableDictionary dictionary];
    }
    [recordedHeapDic setValue:recordedHeap forKey:vcInfo];
    return recordedHeapDic;
}
@end
#endif