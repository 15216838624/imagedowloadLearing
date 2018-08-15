//
//  Item.m
//  图片下载
//
//  Created by 冷武橘 on 2018/7/18.
//  Copyright © 2018年 冷武橘. All rights reserved.
//

#import "Item.h"

@implementation Item
+(instancetype)itemWithDict:(NSDictionary *)dict{
    Item *item=[[Item alloc]init];
    [item setValuesForKeysWithDictionary:dict];
    return item;
}
@end
