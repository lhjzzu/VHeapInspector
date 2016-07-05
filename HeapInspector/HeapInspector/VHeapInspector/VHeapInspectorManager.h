//
//  VHeapInspectorManager.h
//  HeapInspectorLib
//
//  Created by 蚩尤 on 16/5/31.
//  Copyright © 2016年 ouer. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
@interface VHeapInspectorManager : NSObject
/**
 *  这些方法均为内部使用
 */

+ (instancetype)manager;
- (NSArray *)recordWithViewController:(NSString *)vcInfo;
- (NSArray *)removeWithViewController:(NSString *)vcInfo;
/**
 *  当前点击返回的vc的信息
 */
@property (nonatomic,strong) NSString *currentBackVCInfo;

@end
#endif