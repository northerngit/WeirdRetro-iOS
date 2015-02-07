//
//  DataManager.m
//

#import "Managers.h"
#import "BlogPost.h"
#import "Post.h"


@interface DataManager ()

@property (nonatomic, readonly) NSManagedObjectContext *privateWriterContext;

@end


static DataManager *sharedInstance = nil;

@implementation DataManager

@synthesize managedObjectContext=__managedObjectContext;
@synthesize managedObjectModel=__managedObjectModel;
@synthesize persistentStoreCoordinator=__persistentStoreCoordinator;
@synthesize datamodelName;
@synthesize storageName;

+ (DataManager*)sharedInstance
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] init];
        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
        {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;
        }
    }
    return nil;
}

- (id) init {
    self =[super init];
    if (self) {
        self.datamodelName = @"WeirdRetro";
        self.storageName = @"WeirdRetro";
    }
    return self;
}

- (BOOL) contextHasChanges {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
        return [managedObjectContext hasChanges];
    else
        return NO;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
        } 
    }
}

- (void) discardChanges {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        [managedObjectContext rollback];
    }
}


#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    [__managedObjectContext mergeChangesFromContextDidSaveNotification:nil];
    
    if (__threadContext != nil && ![NSThread isMainThread])
        return __threadContext;
    
    
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _privateWriterContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_privateWriterContext setPersistentStoreCoordinator:coordinator];

        __managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        
        __managedObjectContext.parentContext = _privateWriterContext;

    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:datamodelName withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];   
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", storageName]];
    
    //DLog(@"%@", storeURL);
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        //let's try again
        if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }else {
            //DLog(@"\n\n SQLITE WITH OLD MODEL DELETED \n\n");
        }
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - Threads


- (void) startThreadContext
{
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __threadContext = [[NSManagedObjectContext alloc] init];
        [__threadContext setPersistentStoreCoordinator:coordinator];
        [__threadContext setMergePolicy:NSOverwriteMergePolicy];
    }
}

- (void) clearThreadContext
{
    [__managedObjectContext setMergePolicy:NSOverwriteMergePolicy];
    [__threadContext setMergePolicy:NSOverwriteMergePolicy];
    
    [__managedObjectContext mergeChangesFromContextDidSaveNotification:nil];
    [__threadContext mergeChangesFromContextDidSaveNotification:nil];
    
    __threadContext = nil;
    
    
}


#pragma mark - Data manipulating methods

- (id) newObject: (NSString *) entityName {
    id object = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:[self managedObjectContext]];
    return object;
}

- (void) deleteObjects: (NSArray *) objects {
    for (id obj in objects) {
        [[self managedObjectContext] deleteObject:obj];
    }
    [self saveContext];
}




#pragma mark - Fetching

- (NSArray *)fetchEntitiesForClass:(Class)class withSortDescriptors:(NSArray *)sortDescriptors withPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:NSStringFromClass(class)
                                   inManagedObjectContext:self.managedObjectContext]];
    [request setFetchBatchSize:15];
    
    if (sortDescriptors != nil) {
        [request setSortDescriptors:sortDescriptors];
    }
    if (predicate != nil) {
        [request setPredicate:predicate];
    }
    
	NSError *error = nil;
	NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error != nil) {
        DLog(@"Fetch ERROR: %@", [error localizedDescription]);
    }
    
	return result;
}

///////////////////////


- (id)object:(NSString *)entityName
{
    Class EntityClass = NSClassFromString(entityName);
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    NSManagedObject *object = [[EntityClass alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    return object;
}

- (id)object:(NSString *)entityName fromContext:(NSManagedObjectContext*)contextNew
{
    Class EntityClass = NSClassFromString(entityName);
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:contextNew];
    NSManagedObject *object = [[EntityClass alloc] initWithEntity:entity insertIntoManagedObjectContext:contextNew];
    return object;
}


- (id)object:(NSString *)entityName predicate:(NSPredicate *)predicate
{
    NSArray *result = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    request.predicate = predicate;
    [request setFetchLimit:1];
    
    @try
    {
        result = [self.managedObjectContext executeFetchRequest:request error:nil];
    }
    @catch(NSException *exception)
    {
        DLog(@"(!!!) Exception \"%@\", reason: \"%@\"", [exception name], [exception reason]);
    }
    
    return ([result count] == 0 ? nil : [result objectAtIndex:0]);
}


- (id)object:(NSString *)entityName predicate:(NSPredicate *)predicate fromContext:(NSManagedObjectContext*)contextNew {
    NSArray *result = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:contextNew];
    request.predicate = predicate;
    [request setFetchLimit:1];
    
    @try
    {
        NSError *error = nil;
        result = [contextNew executeFetchRequest:request error:&error];
    }
    @catch(NSException *exception)
    {
        DLog(@"(!!!) Exception \"%@\", reason: \"%@\"", [exception name], [exception reason]);
    }
    
    return ([result count] == 0 ? nil : [result objectAtIndex:0]);
}


- (id)object:(NSString *)entityName predicate:(NSPredicate *)predicate sortKey:(NSString*)sortKey ascending:(BOOL) ascending
{
    NSArray *result = nil;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:entity];
    [req setPredicate:predicate];
    
#warning crash
    //    [req setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:[sortKey retain] ascending:ascending]]];
    [req setFetchLimit:1];
    
    @try
    {
        NSError *error = nil;
        result = [self.managedObjectContext executeFetchRequest:req error:&error];
        
        if ( error )
        {
            DLog(@"%@", error.localizedDescription);
        }
    }
    @catch(NSException *exception)
    {
        DLog(@"(!!!) Exception \"%@\", reason: \"%@\"", [exception name], [exception reason]);
    }
    
    return ([result count] == 0 ? nil : [result objectAtIndex:0]);
}


- (NSArray *)objects:(NSString *)entityName {
    NSArray *result = nil;
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:entity];
    @try
    {
        result = [self.managedObjectContext executeFetchRequest:req error:nil];
    }
    @catch(NSException *exception)
    {
        DLog(@"(!!!) Exception \"%@\", reason: \"%@\"", [exception name], [exception reason]);
    }
    
    return ([result count] == 0 ? nil : result);
}


- (NSArray *)objects:(NSString *)entityName fromContext:(NSManagedObjectContext*)contextNew
{
    NSArray *result = nil;
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:contextNew];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:entity];
    @try
    {
        result = [contextNew executeFetchRequest:req error:nil];
    }
    @catch(NSException *exception)
    {
        DLog(@"(!!!) Exception \"%@\", reason: \"%@\"", [exception name], [exception reason]);
    }
    
    return ([result count] == 0 ? nil : result);
}



- (NSUInteger)countObjects:(NSString *)entityName predicate:(NSPredicate*)predicate fromContext:(NSManagedObjectContext*)contextNew
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:contextNew];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:entity];
    [req setPredicate:predicate];
    
    NSUInteger count = -1;
    
    @try
    {
        count = [contextNew countForFetchRequest:req error:nil];
    }
    @catch(NSException *exception)
    {
        DLog(@"(!!!) Exception \"%@\", reason: \"%@\"", [exception name], [exception reason]);
    }
    
    return count;
}

- (NSArray *)objects:(NSString *)entityName predicate:(NSPredicate *)predicate
{
    return [self objects:entityName  predicate:predicate resultType:NSManagedObjectResultType];
}


- (NSArray *)objects:(NSString *)entityName predicate:(NSPredicate *)predicate resultType:(NSFetchRequestResultType)resultType
{
    NSArray *result = nil;
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setResultType:resultType];
    [req setEntity:entity];
    [req setPredicate:predicate];
    
    @try
    {
        result = [self.managedObjectContext executeFetchRequest:req error:nil];
    }
    @catch(NSException *exception)
    {
        DLog(@"(!!!) Exception \"%@\", reason: \"%@\"", [exception name], [exception reason]);
    }
    
    return ([result count] == 0 ? nil : result);
}

- (NSArray *)objects:(NSString *)entityName predicate:(NSPredicate *)predicate fromContext:(NSManagedObjectContext*)contextNew
{
    NSArray *result = nil;
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:contextNew];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:entity];
    [req setPredicate:predicate];
    
    @try
    {
        result = [contextNew executeFetchRequest:req error:nil];
    }
    @catch(NSException *exception)
    {
        DLog(@"(!!!) Exception \"%@\", reason: \"%@\"", [exception name], [exception reason]);
    }
    
    return ([result count] == 0 ? nil : result);
}


- (NSArray *)objects:(NSString *)entityName predicate:(NSPredicate *)predicate sortKey:(NSString*)sortKey ascending:(BOOL) ascending {
    NSArray *result = nil;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:entity];
    [req setPredicate:predicate];
    [req setSortDescriptors:[NSArray arrayWithObjects:[[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending],nil]];
    
    @try
    {
        //        DLog(@"%@, %@", entityName, predicate);
        
        result = [self.managedObjectContext executeFetchRequest:req error:nil];
    }
    @catch(NSException *exception)
    {
        DLog(@"(!!!) Exception \"%@\", reason: \"%@\"", [exception name], [exception reason]);
    }
    
    return ([result count] == 0 ? nil : result);
}



- (NSArray *)objects:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray*)descriptors {
    NSArray *result = nil;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:entity];
    [req setPredicate:predicate];
    [req setSortDescriptors:descriptors];
    
    @try
    {
//        DLog(@"%@, %@", entityName, predicate);
        
        result = [self.managedObjectContext executeFetchRequest:req error:nil];
    }
    @catch(NSException *exception)
    {
        DLog(@"(!!!) Exception \"%@\", reason: \"%@\"", [exception name], [exception reason]);
    }
    
    return ([result count] == 0 ? nil : result);
}



- (NSArray *)objects:(NSString *)entityName predicate:(NSPredicate *)predicate sortKey:(NSString*)sortKey ascending:(BOOL) ascending fromContext:(NSManagedObjectContext*)contextNew {
    
    NSArray *result = nil;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:contextNew];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:entity];
    [req setPredicate:predicate];
    [req setSortDescriptors:[NSArray arrayWithObjects:[[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending],nil]];
    
    @try
    {
        result = [contextNew executeFetchRequest:req error:nil];
    }
    @catch(NSException *exception)
    {
        DLog(@"(!!!) Exception \"%@\", reason: \"%@\"", [exception name], [exception reason]);
    }
    
    return ([result count] == 0 ? nil : result);
}


- (void) deleteObject:(NSManagedObject *)object
{
    if ( object )
    {
        [self.managedObjectContext deleteObject:object];
        [self saveWithSuccess:nil failure:nil];
    }
}


- (void)saveWithSuccess:(SuccessSaving)success failure:(FailureSaving)failure
{
    if (![self.managedObjectContext hasChanges])
    {
        if (success)
        {
            success(NO);
        }
        return;
    }
    
    
    if ( ![[NSThread currentThread] isMainThread] )
    {
        DLog(@"Not main thread!");
    }
    
    //    [self.context setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    
    [self.managedObjectContext performBlockAndWait:^{
        
        //        [self.context lock];
        NSError *error = nil;
        [self.managedObjectContext save:&error];
        
        if (error)
        {
            DLog(@"%@", error.description);
            
            if (failure)
            {
                failure(error);
            }
        }
        else
        {
            [_privateWriterContext performBlockAndWait:^{
                NSError *error = nil;
                [_privateWriterContext save:&error];
                
                if (error)
                {
                    DLog(@"%@", error.description);
                }
                else
                {
                    if (success)
                    {
                        success(YES);
                    }
                }
            }];
        }
        
        
    }];
    
}




- (void) loadBlogPostsFromBackendWithCompletion:(void(^)(NSError* error))completion
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd/MM/yyyy";
    
    [NETWORK loadingHTMLFile:@"captains-blog" withCompletion:^(NSError *error, NSString *htmlMarkup) {
        if ( !error )
        {
            [CONVERTER convertBlogPostPage:htmlMarkup withCompletion:^(WRPage* pageObject) {

                for (WRPage* blogPost in pageObject.items)
                {
                    BlogPost* post = [self object:@"BlogPost" predicate:[NSPredicate predicateWithFormat:@"url = %@", blogPost.url]];
                    if ( !post )
                    {
                        post = [self object:@"BlogPost"];
                        post.url = blogPost.url;
                    }
                    
                    post.title = blogPost.title;
                    post.thumbnailUrl = blogPost.thumbnailUrl;
                    post.content = blogPost.items;
                    post.blogPostIdentity = blogPost.blogPostIdentity;
                    post.dateBlogPost = [formatter dateFromString:blogPost.blogPostDate];
                }
                
                [self saveWithSuccess:nil failure:nil];

                if ( completion )
                    completion(nil);
            }];
        }
        
        if ( completion )
            return completion(error);
    }];
}



- (void) updatingStructureFromBackendWithCompletion:(void(^)(NSError* error))completion
{
    NSArray* sections = [self objects:@"Section"];
    if ( !sections )
    {
        NSArray* sectionsParameters = @[@{@"title":@"Comics corner", @"url":@"comics-corner.html"},
                              @{@"title":@"Cracked Culture", @"url":@"cracked-culture.html"},
                              @{@"title":@"Cult Cinema", @"url":@"cult-cinema.html"},
                              @{@"title":@"Editorial Sarcasm", @"url":@"editorial-sarcasm.html"},
                              @{@"title":@"Far-Out Fiction", @"url":@"far-out-fiction.html"},
                              @{@"title":@"Retro Gaming", @"url":@"retro-gaming.html"},
                              @{@"title":@"Wacky World", @"url":@"wacky-world.html"},
                              @{@"title":@"Weird Music", @"url":@"weird-music.html"}];
        
        NSInteger index = 0;
        
        for (NSDictionary* sectionParameters in sectionsParameters)
        {
            Section* section = [self object:@"Section"];
            section.order = @(index);
            section.title = sectionParameters[@"title"];
            section.url = sectionParameters[@"url"];
            
            index++;
        }
        
        [self saveWithSuccess:nil failure:nil];
        
        sections = [self objects:@"Section"];
    }
    

    __block NSInteger index = 0;
    
    for (Section* section in sections)
    {
        [NETWORK loadingHTMLFile:section.url withCompletion:^(NSError *error, NSString *htmlMarkup) {
            if ( !error )
            {
                [CONVERTER convertPostToStructure:htmlMarkup withCompletion:^(WRPage* pageObject) {
                    
                    NSArray* items = pageObject.items;
                    NSMutableArray* sectionExistItems = [NSMutableArray arrayWithArray:[section.posts allObjects]];
                    
                    NSInteger postIndex = 0;
                    for (NSDictionary* postParams in items)
                    {
                        NSArray* postsTmp = [sectionExistItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"url = %@", postParams[@"link"]]];
                        
                        Post* post = nil;
                        if ( postsTmp.count > 0 )
                        {
                            post = postsTmp[0];
                            [sectionExistItems removeObject:post];
                        }

                        if ( !post )
                        {
                            post = [self object:@"Post"];
                            post.url = postParams[@"link"];
                        }

                        post.title = postParams[@"title"];
                        post.info = postParams[@"info"];
                        post.thumbnailUrl = postParams[@"src"];
                        post.section = section;
                        post.order = @(postIndex);
                        
                        postIndex++;
                        
                        ///////////////
                    }
                    
                    [DATAMANAGER saveWithSuccess:nil failure:nil];

                    index++;
                    if ( index == sections.count && completion )
                        completion(nil);

                }];
            }
        }];
    }
    
}


- (void) updatingPostFromBackendFile:(NSString*)filePath completion:(void(^)(NSError* error))completion
{
    [NETWORK loadingHTMLFile:filePath withCompletion:^(NSError *error, NSString *htmlMarkup) {
        if ( !error )
        {
            [CONVERTER convertPostToStructure:htmlMarkup withCompletion:^(WRPage* pageObject) {
                
                Post* post = [self object:@"Post" predicate:[NSPredicate predicateWithFormat:@"url = %@", filePath]];
                
                if ( post )
                    post.content = pageObject.items;

                [self saveWithSuccess:nil failure:nil];

                if ( completion )
                    completion(nil);
            }];
        }
        
        if ( completion )
            return completion(error);
    }];
}





@end
