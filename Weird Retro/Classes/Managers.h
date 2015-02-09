//
//  Managers.h
//
//  Created by User i7 on 21/01/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import "Debug.h"

#import "NetworkWorker.h"
#define NETWORK [NetworkWorker sharedInstance]

#import "HTMLConverter.h"
#define CONVERTER [HTMLConverter sharedInstance]

#import "DataManager.h"
#define DATAMANAGER [DataManager sharedInstance]

#define kUserId @"38217449"
#define kBlogId @"445815233188664904"
#define kMainTextColor [UIColor colorWithRed:190.f/255.f green:160.f/255.f blue:0 alpha:1.0]

#define kMainTextOptions @{DTDefaultFontName:@"Lato-Regular",\
                        DTDefaultLinkColor:kMainTextColor,\
                        DTDefaultTextColor:[UIColor colorWithRed:98.f/255.f green:98.f/255.f blue:98.f/255.f alpha:1.0],\
                        DTDefaultLinkDecoration:@NO,\
                        DTDefaultFontSize:@13,\
                        DTDefaultLineHeightMultiplier:@1.3f,\
                        DTUseiOS6Attributes:@YES}
