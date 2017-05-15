//
//  CoreDataManagerProtocol.h
//  leapmotor
//
//  Created by 李嘉军 on 16/8/31.
//  Copyright © 2016年 Leapmotor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CoreDataModel.h"

// CoreData管理类的协议
@protocol CoreDataModelManagerProtocol <NSObject>

// 子类必须定义要管理的实体名称
- (NSString *)entityName;

// 必须在每个子类重写将NSManagedObject数据更新到Model的方法
- (void)updateModel:(CoreDataModel *)model byManagedObject:(NSManagedObject *)managedObject;

// 必须在每个子类重写将Model数据更新到NSManagedObject的方法
- (void)updateManagedObject:(NSManagedObject *)managedObject byModel:(CoreDataModel *)model;

// 必须在每个子类重写将NSManagedObject转换成到Model的方法
- (CoreDataModel *)getModelFromManagedObject:(NSManagedObject *)managedObject;

@end
