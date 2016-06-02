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
- (NSSet *)heap;
- (NSArray *)getRecordedVCArr;
- (NSDictionary *)getRecordedHeapDic;
- (NSArray *)recordWithViewController:(NSString *)vcInfo;
- (NSMutableDictionary *)recordedHeapDicWithRecordedHeap:(NSSet *)recordedHeap withVCInfo:(NSString *)vcInfo;
@end
#endif