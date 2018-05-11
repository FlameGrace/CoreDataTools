//
//  CoreDataManager.m
//  leapmotor
//
//  Created by lijj on 16/8/31.
//  Copyright © 2016年 leapmotor. All rights reserved.
//

#import "CoreDataModelManager.h"
#import "CoreDataContext.h"

@implementation CoreDataModelManager

+ (instancetype)manager
{
    return [[self alloc]init];
}

- (instancetype)init
{
    if(self = [super init])
    {
        self.managedContext = [[CoreDataContext sharedContext] generateNewPrivateQueueContext];
    }
    return self;
}

- (NSString *)entityName
{
    return nil;
}


- (id<CoreDataModelProtocol>)getModelFromManagedObject:(NSManagedObject *)managedObject
{
    return nil;
}


- (NSMutableArray <id<CoreDataModelProtocol>> *)getModelsFromManagedObjects:(NSArray <NSManagedObject *> *)managedObjects
{
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    for (NSManagedObject *managedObject in managedObjects) {
        id<CoreDataModelProtocol>model = [self getModelFromManagedObject:managedObject];
        if(model)[arr addObject:model];
    }
    if([arr count] < 1) return nil;
    return arr;
}

- (void)updateManagedObject:(NSManagedObject *)managedObject byModel:(id<CoreDataModelProtocol>)model
{
    
}

- (void)updateModel:(id<CoreDataModelProtocol>)model byManagedObject:(NSManagedObject *)managedObject
{
    
}


- (BOOL)update:(id<CoreDataModelProtocol>)model
{
    if(!model||!model.managedObjectID)return NO;
    [self updateManagedObject:[self.managedContext objectWithID:model.managedObjectID] byModel:model];
    return [self save];
}


- (BOOL)createNewManagedObjectByModel:(id<CoreDataModelProtocol>)model
{
    NSManagedObject *managedObject =[NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:self.managedContext];
    [self updateManagedObject:managedObject byModel:model];
    if([self save])
    {
        model.managedObjectID = managedObject.objectID;
        return YES;
    }
    return NO;
}


- (BOOL)removeManagedObject:(NSManagedObjectID *)managedObjectID
{
    if(!managedObjectID)return NO;
    [self.managedContext deleteObject:[self.managedContext objectWithID:managedObjectID]];
    return [self save];
}

- (BOOL)save
{
    NSError *error;
    if(![[CoreDataContext sharedContext] saveContext:self.managedContext error:&error])
    {
        return NO;
    }
    return YES;
}

- (NSMutableArray <id<CoreDataModelProtocol>> *)queryAll
{

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    NSArray *array = [self.managedContext executeFetchRequest:request error:nil];
    
    return [self getModelsFromManagedObjects:array];
}

- (BOOL)removeAll
{
    NSArray *records = [self queryAll];
    __block BOOL remove = YES;
    [records enumerateObjectsUsingBlock:^(id<CoreDataModelProtocol>obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(![self removeManagedObject:obj.managedObjectID])
        {
            remove = NO;
            *stop = YES;
        }
    }];
    return remove;
}

- (NSMutableArray<id<CoreDataModelProtocol>> *)queryWithPredicateFormat:(NSString *)format value:(id)value sortKey:(NSString *)sortKey asc:(BOOL)asc
{
    return [self queryWithPredicateFormat:format value:value sortKey:sortKey asc:asc limit:0 offset:0];
}

- (NSMutableArray <id<CoreDataModelProtocol>> *)queryWithPredicateFormat:(NSString *)format value:(id)value limit:(NSInteger)limit offset:(NSInteger)offset
{
    return [self queryWithPredicateFormat:format value:value sortKey:nil asc:NO limit:limit offset:offset];
}

- (NSMutableArray<id<CoreDataModelProtocol>> *)queryWithPredicateFormat:(NSString *)format value:(id)value sortKey:(NSString *)sortKey asc:(BOOL)asc limit:(NSInteger)limit offset:(NSInteger)offset
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    NSPredicate *predict = [NSPredicate predicateWithFormat:format,value];
    [request setPredicate:predict];
    
    if(limit > 0 && offset >= 0)
    {
        [request setFetchLimit:limit];
        [request setFetchOffset:offset];
    }
    if(sortKey && sortKey.length > 0)
    {
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:sortKey ascending:asc];
        [request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
    }
    
    NSArray *array = [self.managedContext executeFetchRequest:request error:nil];
    return [self getModelsFromManagedObjects:array];
}



- (NSMutableArray<id<CoreDataModelProtocol>> *)queryWithPredicateFormat:(NSString *)format value:(id)value
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    
    NSPredicate *predict = [NSPredicate predicateWithFormat:format,value];
    [request setPredicate:predict];
    
    NSArray *array = [self.managedContext executeFetchRequest:request error:nil];
    
    return [self getModelsFromManagedObjects:array];
}



@end
