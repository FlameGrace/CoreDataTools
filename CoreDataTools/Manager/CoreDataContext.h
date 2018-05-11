//
//  CoreDataContext.h
//  manydb
//
//  Created by lijj on 16/10/18.
//  Copyright © 2016年 hello. All rights reserved.
//  可以切换数据库

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>




@interface CoreDataContext : NSObject

@property (strong, nonatomic) NSString *modeldName;
//@property (readonly, strong, nonatomic) NSManagedObjectContext *mainQueueObjectContext;//主线程Context,UI刷新时用到的context
//@property (readonly, strong, nonatomic) NSManagedObjectContext *backgroundObjectContext;//异步线程Context,异步保存数据，防止主线程阻塞
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
//@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;


/**
 共享单例

 @return CoreDataContext对象
 */
+ (instancetype)sharedContext;

/**
 每个子线程进行数据操作时需要在自己的线程创建私有Context进行操作

 @return 新创建的Context，如果在主线程调用该方法则返回mainQueueObjectContext
 */
-(NSManagedObjectContext *)generateNewPrivateQueueContext;

/**
 初始化指向给定文件名的XCDataModeld文件的对象

 @param modeldName 给定文件名的XCDataModeld文件
 @return CoreDataContext对象
 */
- (id)initWithXCDataModeldName:(NSString *)modeldName;

/**
 调用此方法，将childContext的更新同步到parentContext中，在childContext调用save方法后必须调用此方法
 */
- (void)saveContext;

/**
 调用context的save方法，并默认将结果同步到parentContext中

 @param context childContext
 @param error 保存出错时的错误信息
 @return 是否成功保存
 */
- (BOOL)saveContext:(NSManagedObjectContext *)context error:(NSError **)error;

@end
