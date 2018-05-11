//
//  CoreDataModelProtocol.h
//  SpeexChat
//
//  Created by 李嘉军 on 2017/7/25.
//  Copyright © 2017年 leapmotor. All rights reserved.
//

#import <CoreData/CoreData.h>

@protocol CoreDataModelProtocol <NSObject>

// 保存对应的NSManagedObject对象的ID
@property (nonatomic, strong) NSManagedObjectID *managedObjectID;

@end
