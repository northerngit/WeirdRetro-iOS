//
//  DataManager.h
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


typedef void(^SuccessSaving)(BOOL hasChanges);
typedef void(^FailureSaving)(NSError *error);

@interface DataManager : NSObject {
    NSManagedObjectContext *__threadContext;
    NSString *datamodelName;
    NSString *storageName;
}

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSString *datamodelName;
@property (nonatomic, strong) NSString *storageName;

+ (DataManager *) sharedInstance;
- (NSURL *) applicationDocumentsDirectory;
- (BOOL) contextHasChanges;
- (void) saveContext;
- (void) discardChanges;
- (void) startThreadContext;
- (void) clearThreadContext;



- (id) object:(NSString *)entityName;
- (id) object:(NSString *)entityName fromContext:(NSManagedObjectContext*)contextNew;

- (id) object:(NSString *)entityName predicate:(NSPredicate *)predicate;
- (id) object:(NSString *)entityName predicate:(NSPredicate *)predicate fromContext:(NSManagedObjectContext*)contextNew;
- (id)object:(NSString *)entityName predicate:(NSPredicate *)predicate sortKey:(NSString*)sortKey ascending:(BOOL) ascending;

- (NSArray*) objects:(NSString *)entityName;
- (NSArray*) objects:(NSString *)entityName predicate:(NSPredicate *)predicate;
- (NSArray *)objects:(NSString *)entityName predicate:(NSPredicate *)predicate resultType:(NSFetchRequestResultType)resultType;
- (NSArray *)objects:(NSString *)entityName predicate:(NSPredicate *)predicate fromContext:(NSManagedObjectContext*)contextNew;

- (int) countObjects:(NSString *)entityName predicate:(NSPredicate*)predicate fromContext:(NSManagedObjectContext*)contextNew;

- (NSArray*) objects:(NSString *)entityName predicate:(NSPredicate *)predicate sortKey:(NSString*)sortKey ascending:(BOOL) ascending;
- (NSArray *)objects:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray*)descriptors;
- (NSArray *)objects:(NSString *)entityName predicate:(NSPredicate *)predicate sortKey:(NSString*)sortKey ascending:(BOOL) ascending fromContext:(NSManagedObjectContext*)contextNew;

- (void) deleteObject:(NSManagedObject *)object;


- (void)saveWithSuccess:(SuccessSaving)success failure:(FailureSaving)failure;


- (id) newObject: (NSString *) entityName;
- (void) deleteObjects: (NSArray *) objects;

- (NSArray *)fetchEntitiesForClass:(Class)class withSortDescriptors:(NSArray *)sortDescriptors withPredicate:(NSPredicate *)predicate;


@property (nonatomic, strong) NSMutableArray* blogPosts;
@property (nonatomic, strong) NSMutableDictionary* posts;

- (void) updatingStructureFromBackendWithCompletion:(void(^)(NSError* error))completion;
- (void) updatingPostFromBackendFile:(NSString*)filePath completion:(void(^)(NSError* error))completion;

- (void) loadBlogPostsFromBackendWithCompletion:(void(^)(NSError* error))completion;

@end