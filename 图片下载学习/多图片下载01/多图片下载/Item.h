//
//  Item.h
//  多图片下载
//
//  Created by 冷武橘 on 2018/7/9.
//  Copyright © 2018年 冷武橘. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *download;
+(instancetype)itemwithDic:(NSDictionary *)dictionary;
@end
