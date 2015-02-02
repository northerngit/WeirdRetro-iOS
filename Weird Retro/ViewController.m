//
//  ViewController.m
//  Weird Retro
//
//  Created by User i7 on 01/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import "ViewController.h"
#import "HTMLReader.h"
#import "HTMLParser.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    NSString *markup = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"superhero" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
    
    HTMLDocument *document = [HTMLDocument documentWithString:markup];
    HTMLElement* element = [document firstNodeMatchingSelector:@"[id=\"wsite-content\"]"];
    
//    [element firstNodeMatchingSelector:@""]
    
    //    for (HTMLElement* elementCh in element.children) {
            NSLog(@"%@", element);
    //    }
    
    
    // => Ahoy there sailor!
    // Wrap one element in another.
    HTMLElement *b = [document firstNodeMatchingSelector:@"[id=\"wsite-content\"]"];
    NSMutableOrderedSet *children = [b.parentNode mutableChildren];
    HTMLElement *wrapper = [[HTMLElement alloc] initWithTagName:@"div"
                                                     attributes:@{@"class": @"special"}];
    [children insertObject:wrapper atIndex:[children indexOfObject:b]];
    b.parentNode = wrapper;

    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

@end
