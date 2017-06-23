//
//  LMCoreDataModel.h
//  flamegrace@hotmail.com
//
//  Created by Flame Grace on 16/8/31.
//  Copyright © 2016年 flamegrace@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

// CoreData NSManagedObject转换后模型基类
@interface CoreDataModel : NSObject

+ (instancetype)model;

// 保存对应的NSManagedObject对象的ID
@property (nonatomic, strong) NSManagedObjectID *managedObjectID;

@end
