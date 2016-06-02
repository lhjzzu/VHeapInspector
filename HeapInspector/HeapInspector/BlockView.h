//
//  BlockView.h
//  HeapInspector
//
//  Created by 蚩尤 on 16/6/1.
//  Copyright © 2016年 ouer. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^Block) ();
@interface BlockView : UIView

@property (nonatomic,strong) Block block;

@end
