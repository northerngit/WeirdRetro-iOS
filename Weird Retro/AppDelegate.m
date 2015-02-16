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
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "CustomURLCache.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self importFonts];
    
    CustomURLCache *URLCache = [[CustomURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
                                                         diskCapacity:200 * 1024 * 1024
                                                             diskPath:nil];
    
    [NSURLCache setSharedURLCache:URLCache];
    
    return YES;
}


- (void) printAvailableFonts {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *familyNames = [UIFont familyNames];
    for (NSString *family in familyNames) {
        NSArray *fonts = [UIFont fontNamesForFamilyName:family];
        if (fonts) {
            dict[family] = fonts;
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
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
