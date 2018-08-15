//
//  Item.m
//  多图片下载
//
//  Created by 冷武橘 on 2018/7/9.
//  Copyright © 2018年 冷武橘. All rights reserved.
//

#import "Item.h"

@implementation Item
+(instancetype)itemwithDic:(NSDictionary *)dictionary{
    Item *items=[[Item alloc]init];
    [items setValuesForKeysWithDictionary:dictionary];
    return items;
}
@end
