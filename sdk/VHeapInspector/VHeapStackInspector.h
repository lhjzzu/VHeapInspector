//
//  VHeapStackInspector.h
//  HeapInspectorLib
//
//  Created by 蚩尤 on 16/5/31.
//  Copyright © 2016年 ouer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VHeapStackInspector : NSObject
+ (void)addClassPrefixesToRecord:(NSArray *)prefixes;
+ (void)ignoreClassNamesToRecord:(NSArray *)classNames;
+ (NSSet *)heap;
@end
