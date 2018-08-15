//
//  ViewController.m
//  多图片下载
//
//  Created by 冷武橘 on 2018/7/9.
//  Copyright © 2018年 冷武橘. All rights reserved.
//

#import "ViewController.h"
#import "Item.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong) NSArray * itemArray;
@property(nonatomic, strong) NSMutableDictionary * images;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSMutableDictionary *operatios;
@end

@implementation ViewController
- (NSArray *)itemArray{
    if (_itemArray==nil) {
        NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"apps.plist" ofType:nil]];
        NSMutableArray *arrayM=[NSMutableArray array];
        for (NSDictionary *dic in array) {
            [arrayM addObject:[Item itemwithDic:dic]];
        }
        _itemArray=arrayM;
    }
    return _itemArray;
}
- (NSMutableDictionary *)images{
    if (_images==nil) {
        _images=[NSMutableDictionary dictionary];
    }
    return _images;
}
-(NSOperationQueue *)queue
{
    if (_queue == nil) {
        _queue = [[NSOperationQueue alloc]init];
    }
    return _queue;
}

-(NSMutableDictionary *)operatios
{
    if (_operatios == nil) {
        _operatios = [NSMutableDictionary dictionary];
    }
    return _operatios;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    UITableView *tableview=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    tableview.estimatedSectionFooterHeight=0;
    tableview.estimatedSectionHeaderHeight=0;
    tableview.estimatedRowHeight=0;
    tableview.delegate=self;
    tableview.dataSource=self;
    tableview.rowHeight=100;
    [self.view addSubview:tableview];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.itemArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] ;
        //cell的四种样式
        //UITableViewCellStyleDefault, 只显示图片和标题
        //UITableViewCellStyleValue1, 显示图片，标题和子标题（子标题在右边）
        //UITableViewCellStyleValue2, 标题和子标题
        //UITableViewCellStyleSubtitle 显示图片，标题和子标题（子标题在下边）
        
    }
    
   Item *item=self.itemArray[indexPath.row];
    cell.textLabel.text=item.name;
    NSURL *url=[NSURL URLWithString:item.icon];
    NSData *imagedata=[NSData dataWithContentsOfURL:url];
    UIImage *image=[UIImage imageWithData:imagedata];

    cell.imageView.image=image;
 
    return cell;
}

@end
