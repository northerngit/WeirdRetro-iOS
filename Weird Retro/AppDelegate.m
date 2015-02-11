//
//  AppDelegate.m
//  Weird Retro
//
//  Created by User i7 on 01/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import "AppDelegate.h"
#import "Managers.h"
#import <dlfcn.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self importFonts];
    [self printAvailableFonts];
    
//    NSString* htmlMarkup = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"postwithcomments" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
//    [CONVERTER convertBlogPostToStructure:htmlMarkup withCompletion:^(WRPage* pageObject) {
//    }];

//    [CONVERTER convertPostToStructure:htmlMarkup withCompletion:^(WRPage* pageObject) {
//    }];
    
    [NETWORK submitContactFormWithFirstName:@"Alex" lastName:@"True" email:@"troohin@gmail.com" type:@"General Comment" comment:@"Comment" withCompletion:^(NSError *error) {
        
    }];
    
    return YES;
}


- (void) printAvailableFonts {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *familyNames = [UIFont familyNames];
    for (NSString *family in familyNames) {
        NSArray *fonts = [UIFont fontNamesForFamilyName:family];
        if (fonts) {
            [dict setObject:fonts forKey:family];
        }
    }
    
    DLog(@"fonts = %@", dict);
}

- (void) importFonts {
    BOOL GSFontAddFromFile(const char * path);
    NSUInteger newFontCount = 0;
    NSBundle *frameworkBundle = [NSBundle bundleWithIdentifier:@"com.apple.GraphicsServices"];
    const char *frameworkPath = [[frameworkBundle executablePath] UTF8String];
    if (frameworkPath) {
        void *graphicsServices = dlopen(frameworkPath, RTLD_NOLOAD | RTLD_LAZY);
        if (graphicsServices) {
            BOOL (*GSFontAddFromFile)(const char *) = dlsym(graphicsServices, "GSFontAddFromFile");
            if (GSFontAddFromFile) {
                for (NSString *fontFile in [[NSBundle mainBundle] pathsForResourcesOfType:@"ttf" inDirectory:nil])
                    newFontCount += GSFontAddFromFile([fontFile UTF8String]);
                
                for (NSString *fontFile in [[NSBundle mainBundle] pathsForResourcesOfType:@"otf" inDirectory:nil])
                    newFontCount += GSFontAddFromFile([fontFile UTF8String]);
            }
        }
    }
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
