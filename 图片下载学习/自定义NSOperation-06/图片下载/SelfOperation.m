//
//  SelfOperation.m
//  图片下载
//
//  Created by 冷武橘 on 2018/7/19.
//  Copyright © 2018年 冷武橘. All rights reserved.
//

#import "SelfOperation.h"

@implementation SelfOperation
- (void)main{
    NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:self.url]];
    if ([self.delegate respondsToSelector:@selector(downLoadOperation:didFishedDownLoad:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{//回到主线程，传递数据给代理对象
        [self.delegate downLoadOperation:self didFishedDownLoad:data];
        });
    }
}
@end
