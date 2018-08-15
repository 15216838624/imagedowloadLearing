//
//  SelfOperation.h
//  图片下载
//
//  Created by 冷武橘 on 2018/7/19.
//  Copyright © 2018年 冷武橘. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SelfOperation;
@protocol DownLoadDelegate <NSObject>
 -(void)downLoadOperation:(SelfOperation*)operation didFishedDownLoad:(NSData *)imagedata;
@end
@interface SelfOperation : NSOperation
@property(nonatomic,strong)NSString *url;
@property(nonatomic,strong)NSIndexPath *indexpath;
@property(nonatomic,weak)id <DownLoadDelegate> delegate;
@end
