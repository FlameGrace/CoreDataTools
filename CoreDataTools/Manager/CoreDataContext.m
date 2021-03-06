//
//  CoreDataContext.m
//  manydb
//
//  Created by lijj on 16/10/18.
//  Copyright © 2016年 hello. All rights reserved.
//

#import "CoreDataContext.h"

typedef void(^ContextSaveBlock)(void);

@interface CoreDataContext()

@property (strong, nonatomic) dispatch_queue_t backgroundContextQueue;
@property (strong, nonatomic) NSManagedObjectContext *backgroundObjectContext;//异步线程Context,异步保存数据，防止主线程阻塞

@end

@implementation CoreDataContext

@synthesize backgroundObjectContext = _backgroundObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static CoreDataContext *sharedContext = nil;

+ (instancetype)sharedContext
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedContext = [[self alloc]init];
    });
    
    return sharedContext;
}

- (id)initWithXCDataModeldName:(NSString *)modeldName
{
    if(self = [super init])
    {
        self.modeldName = modeldName;
        [self generateBackgroundObjectContext];
    }
    return self;
}

- (instancetype)init
{
    if(self = [super init])
    {
        [self generateBackgroundObjectContext];
    }
    return self;
}

- (void)generateBackgroundObjectContext
{
    dispatch_async(self.backgroundContextQueue, ^{
        [self backgroundObjectContext];
    });
}


- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.leapmotor.testleapmotor.Testleapmotor" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:[self modeldName] withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",[self modeldName]]];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    NSDictionary *configuration = @{NSMigratePersistentStoresAutomaticallyOption:@YES,NSInferMappingModelAutomaticallyOption:@YES};
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:configuration error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)backgroundObjectContext
{
    if (_backgroundObjectContext != nil) {
        return _backgroundObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _backgroundObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_backgroundObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _backgroundObjectContext;
}

- (NSManagedObjectContext *)generateNewPrivateQueueContext
{
    NSManagedObjectContext *context = [[self class]generatePrivateContextWithParent:[self backgroundObjectContext]];
    return context;
}

#pragma mark - Core Data Saving support

- (void)saveContextAndWait:(BOOL)needWait
{
    NSManagedObjectContext *backgroundObjectContext = [self backgroundObjectContext];
    
    if (nil == backgroundObjectContext) {
        return;
    }
    
     ContextSaveBlock saveBlock = ^ {
         NSError *error = nil;
         if (![backgroundObjectContext save:&error]) {
             NSLog(@"Save root context failed and error is %@", error);
         }
    };
    
    if ([backgroundObjectContext hasChanges]) {
        if (needWait) {
            [backgroundObjectContext performBlockAndWait:saveBlock];
        }
        else {
            [backgroundObjectContext performBlock:saveBlock];
        }
    }
}

- (void)saveContext
{
    [self saveContextAndWait:NO];
}

- (BOOL)saveContext:(NSManagedObjectContext *)context error:(NSError **)error
{
    if(context == nil)
    {
        return YES;
    }
    if ([context hasChanges]) {
        if([context save:error])
        {
            [self saveContext];
            return YES;
        }
        else
        {
            if(error != NULL)
            {
                NSLog(@"CoreData save error: %@!",*error);
            }
            return NO;
        }
    }
    return YES;
}

+ (NSManagedObjectContext *)generatePrivateContextWithParent:(NSManagedObjectContext *)parentContext
{
    NSManagedObjectContext *privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    privateContext.parentContext = parentContext;
    return privateContext;
}


- (dispatch_queue_t)backgroundContextQueue
{
    if(!_backgroundContextQueue)
    {
        _backgroundContextQueue = dispatch_queue_create("BackgroundCoreDataContextQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _backgroundContextQueue;
}

@end
