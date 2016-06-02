

//
//  VTableViewCell.m
//  HeapInspector
//
//  Created by 蚩尤 on 16/5/28.
//  Copyright © 2016年 ouer. All rights reserved.
//

#import "VTableViewCell.h"

@implementation VTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      //造成循环引用
      // [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(time:) userInfo:nil repeats:YES];
    }
    return self;
}
- (void)time:(NSTimer *)time {

}

@end
