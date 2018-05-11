//
//  LMCoreDataModel.h
//  leapmotor
//
//  Created by lijj on 16/8/31.
//  Copyright © 2016年 leapmotor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CoreDataModelProtocol.h"

// CoreData NSManagedObject转换后模型基类
@interface CoreDataModel : NSObject <CoreDataModelProtocol>

+ (instancetype)model;

@end
