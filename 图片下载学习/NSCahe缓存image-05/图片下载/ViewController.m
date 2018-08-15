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
@property(nonatomic, strong) NSCache * imagecahe;
@property(nonatomic, strong) NSOperationQueue * operationque;
@property(nonatomic, strong) NSMutableDictionary * opearationce;
@end
/*1. NSCache简单说明
 1）NSCache是苹果官方提供的缓存类，具体使用和NSMutableDictionary类似，在AFN和SDWebImage框架中被使用来管理缓存
 2）苹果官方解释NSCache在系统内存很低时，会自动释放对象（但模拟器演示不会释放）
 建议：接收到内存警告时主动调用removeAllObject方法释放对象
 3）NSCache是线程安全的，在多线程操作中，不需要对NSCache加锁
 4）NSCache的Key只是对对象进行Strong引用，不是拷贝，在清理的时候计算的是实际大小而不是引用的大小
 
 2. NSCache属性和方法介绍
 1）属性介绍
 name:名称
 delegete:设置代理
 totalCostLimit：缓存空间的最大总成本，超出上限会自动回收对象。默认值为0，表示没有限制
 countLimit：能够缓存的对象的最大数量。默认值为0，表示没有限制
 evictsObjectsWithDiscardedContent：标识缓存是否回收废弃的内容
 2）方法介绍
 - (void)setObject:(ObjectType)obj forKey:(KeyType)key;//在缓存中设置指定键名对应的值，0成本
 - (void)setObject:(ObjectType)obj forKey:(KeyType)keycost:(NSUInteger)g;
 //在缓存中设置指定键名对应的值，并且指定该键值对的成本，用于计算记录在缓存中的所有对象的总成本
 //当出现内存警告或者超出缓存总成本上限的时候，缓存会开启一个回收过程，删除部分元素
 - (void)removeObjectForKey:(KeyType)key;//删除缓存中指定键名的对象
 - (void)removeAllObjects;//删除缓存中所有的对象
 */
@implementation ViewController
- (NSCache *)imagecahe{
    if (_imagecahe==nil) {
        _imagecahe=[[NSCache alloc]init];
    }
    return _imagecahe;
}
- (NSMutableDictionary *)opearationce{
    if (_opearationce==nil) {
        _opearationce=[NSMutableDictionary dictionary];
    }
    return _opearationce;
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
        
            NSBlockOperation *download=[self.opearationce objectForKey:item.icon];
            if (download) {
                NSLog(@"正在下载中");
            }else
            {
            
            NSBlockOperation *blockoperation=[NSBlockOperation blockOperationWithBlock:^{
                NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:item.icon]];
                UIImage *image=[UIImage imageWithData:data];
                for (int i=0; i<10000;i++) {
                    NSLog(@"耗时操作");
                }
                //保存到沙盒里
                [data writeToFile:fullpath atomically:YES];
                //保存到内存
                [self.imagecahe setObject:image forKey:item.icon];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                    cell.imageView.image=image;
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }];
            }];
            [self.operationque addOperation:blockoperation];
                [self.opearationce setObject:blockoperation forKey:item.icon];
            }
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
