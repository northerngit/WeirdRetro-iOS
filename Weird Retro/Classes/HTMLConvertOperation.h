//
//  HTMLConvertOperation.h
//  Weird Retro
//
//  Created by User i7 on 03/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CustomOperationCompletionBlock)(NSArray* items);

@interface HTMLConvertOperation : NSOperation

@property (nonatomic, assign) CustomOperationCompletionBlock successFailureBlock;
@property (nonatomic, strong) NSString* htmlMarkup;
@property (nonatomic, assign) NSInteger type;

//- (id)initWithURL:(NSURL *)url successFailureBlock:(CustomOperationCompletionBlock)successFailureBlock;

@end
