//
//  HTMLConvertOperation.h
//  Weird Retro
//
//  Created by User i7 on 03/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WRPage.h"


typedef void(^CustomOperationCompletionBlock)(WRPage* pageObject);

@interface HTMLConvertOperation : NSOperation

@property (nonatomic, assign) CustomOperationCompletionBlock successFailureBlock;
@property (nonatomic, assign) PageType type;
@property (nonatomic, copy) NSString* htmlMarkup;

@end
