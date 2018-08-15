//
//  ViewController.m
//  图片下载
//
//  Created by 冷武橘 on 2018/7/18.
//  Copyright © 2018年 冷武橘. All rights reserved.
//

#import "ViewController.h"
#import "Item.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSArray *Items;
@property(nonatomic, strong) NSMutableDictionary * imagecahe;
@property(nonatomic, strong) NSOperationQueue * operationque;
@end

@implementation ViewController
- (NSMutableDictionary *)imagecahe{
    if (_imagecahe==nil) {
        _imagecahe=[NSMutableDictionary dictionary];
    }
    return _imagecahe;
}
- (NSOperationQueue *)operationque{
    if (_operationque==nil) {
        _operationque=[[NSOperationQueue alloc]init];
    }
    return _operationque;
}

-(NSArray *)Items{
    if (_Items==nil) {
        NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"apps.plist" ofType:nil]];
        NSMutableArray *arrM = [NSMutableArray array];
        for (NSDictionary *dict in array) {
            [arrM addObject:[Item itemWithDict:dict]];
        }
        _Items = arrM;
    }
    return _Items;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    UITableView *tableview=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    tableview.rowHeight=80;
    tableview.estimatedSectionFooterHeight=0;
    tableview.estimatedSectionHeaderHeight=0;
    tableview.estimatedRowHeight=0;
    tableview.delegate=self;
    tableview.dataSource=self;
    [self.view addSubview:tableview];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID=@"cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:ID];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle: UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    Item *item = self.Items[indexPath.row];
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = item.download;
    UIImage *image=[self.imagecahe objectForKey:item.icon];
    //01、检查内存
    if (image) { //检查内存里有图片，直接显示加载图片
        cell.imageView.image=image;
    }
    //02、检查缓存
    else{
        NSString *fullpath=[self getfullpathwithiconName:item.icon];
        NSData *imagedata=[NSData dataWithContentsOfFile:fullpath];
        if (imagedata) {//内存里没有图片，再检查沙盒里有图片，就去读取沙盒里的图片
            UIImage *image = [UIImage imageWithData:imagedata];
            cell.imageView.image = image;
            
            //保存到内存
            [self.imagecahe setObject:image forKey:item.icon];
        }
        else{//内存、缓存里都没有图片
            for (int i=0; i<10000;i++) {
                NSLog(@"耗时操作");
            }
            NSBlockOperation *blockoperation=[NSBlockOperation blockOperationWithBlock:^{
                NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:item.icon]];
                UIImage *image=[UIImage imageWithData:data];
              
                //保存到沙盒里
                [data writeToFile:fullpath atomically:YES];
                //保存到内存
                [self.imagecahe setObject:image forKey:item.icon];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    //cell.imageView.image=image;
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }];
            }];
            [self.operationque addOperation:blockoperation];
        }
    }
    return cell;
}

#pragma mark -获得一个全路径
- (NSString *)getfullpathwithiconName:(NSString *)icon{
    NSString *fileName = [icon lastPathComponent];
    NSString *cache=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    NSString *fullPath = [cache stringByAppendingPathComponent:fileName];
    return fullPath;
}


@end
