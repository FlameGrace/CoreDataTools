//
//  LMCoreDataModel.m
//  leapmotor
//
//  Created by lijj on 16/8/31.
//  Copyright © 2016年 leapmotor. All rights reserved.
//

#import "CoreDataModel.h"


@implementation CoreDataModel

@synthesize managedObjectID = _managedObjectID;

+ (instancetype)model
{
    return [[self alloc]init];
}


@end
