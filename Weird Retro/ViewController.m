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
{
    BOOL started;
    NSMutableArray* array;
    
}


@end

@implementation ViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    NSString *markup = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"japanese" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
    
    array = [NSMutableArray new];
    
    HTMLDocument *document = [HTMLDocument documentWithString:markup];
    HTMLElement* element = [document firstNodeMatchingSelector:@"[id=\"wsite-content\"]"];

    [self startParsing1:element];
    
    
    NSLog(@"%@", array);
    
//    HTMLElement *b = [document firstNodeMatchingSelector:@"[id=\"wsite-content\"]"];
//    NSMutableOrderedSet *children = [b.parentNode mutableChildren];
//    HTMLElement *wrapper = [[HTMLElement alloc] initWithTagName:@"div"
//                                                     attributes:@{@"class": @"special"}];
//    [children insertObject:wrapper atIndex:[children indexOfObject:b]];
//    b.parentNode = wrapper;
}


//[self startParsing2:element];

//    HTMLElement *b = [document firstNodeMatchingSelector:@"[id=\"wsite-content\"]"];
//    NSMutableOrderedSet *children = [b.parentNode mutableChildren];
//    HTMLElement *wrapper = [[HTMLElement alloc] initWithTagName:@"div"
//                                                     attributes:@{@"class": @"special"}];
//    [children insertObject:wrapper atIndex:[children indexOfObject:b]];
//    b.parentNode = wrapper;




//- (void) startParsing2:(HTMLElement*)contentElement
//{
//    NSArray* elements = [contentElement nodesMatchingSelector:@"div+hr"];
//    NSLog(@"%@", elements);
//    
//    //    for (HTMLNode* childrenNode in contentElement.children)
//    //    {
//    //        if ( [childrenNode isKindOfClass:[HTMLElement class]] )
//    //        {
//    //            HTMLElement* childrenElement = (HTMLElement*)childrenNode;
//    //        }
//    //
//    //    }
//}


- (void) startParsing1:(HTMLElement*)contentElement
{
    for (HTMLNode* childrenNode in contentElement.children)
    {
        [self parseNode:childrenNode level:0];
    }
    
}

- (void) parseNode:(HTMLNode*)node level:(NSInteger)level
{
    if ( [node isKindOfClass:[HTMLElement class]] )
    {
        HTMLElement* element = (HTMLElement*)node;
        if ( [element.tagName isEqualToString:@"div"] )
        {
            NSString* class = element.attributes[@"class"];
            if ( class )
            {
                // Multiple columns
                if ( [class isEqualToString:@"wsite-multicol"] )
                {
                    NSArray* trMulticolumns = [element nodesMatchingSelector:@"[class=\"wsite-multicol-col\"]"];
                    
                    for (HTMLNode* tdColumn in trMulticolumns)
                        [self parseNode:tdColumn level:level++];
                }
                // Image
                else if ( [class rangeOfString:@"wsite-image"].location != NSNotFound  )
                {
                    [self parseImageDIV:element];
                }
                // Text
                else if ( [class isEqualToString:@"paragraph"] )
                {
                    [self parseTextDIV:element];
                }

            }
            else
            {
                for (HTMLNode* childrenNode in element.children)
                    [self parseNode:childrenNode level:level++];
            }
        }
        else if ( [element.tagName isEqualToString:@"span"] && element.attributes[@"class"] )
        {
            if ( [element.attributes[@"class"] isEqualToString:@"imgPusher"] )
            {
                [self parseImagedLink:element];
            }
            else if ( [element.attributes[@"class"] rangeOfString:@"imdbRatingPlugin"].location != NSNotFound )
            {
                [self parseIMDBSpan:element];
            }
        }
        else if ( [element.tagName isEqualToString:@"hr"] && element.attributes[@"class"] && [element.attributes[@"class"] isEqualToString:@"styled-hr"] )
        {
            [self parseHR];
        }
        else
        {
            for (HTMLNode* childrenNode in element.children)
                [self parseNode:childrenNode level:level++];
        }
    }

    
    ///////////
}



- (void) parseImagedLink:(HTMLElement*)element
{
    if ( !element.parentElement )
        return;
    
    NSUInteger index = [element.parentElement indexOfChild:element];
    if ( index + 3 > element.parentElement.numberOfChildren )
        return;

    HTMLNode* spanElement = [element.parentElement childAtIndex:index+1];
    
    if ( spanElement &&
        [spanElement isKindOfClass:[HTMLElement class]] &&
        [[(HTMLElement*)spanElement tagName] isEqualToString:@"span"] )
    {
        HTMLNode* imgNode = [[element.parentElement childAtIndex:index+1] firstNodeMatchingSelector:@"img"];
        HTMLNode* descriptionNode = [element.parentElement childAtIndex:index+2];
        
        NSLog(@"%@", descriptionNode);
        
        if ( imgNode && [imgNode isKindOfClass:[HTMLElement class]] &&
            descriptionNode && [descriptionNode isKindOfClass:[HTMLElement class]])
        {
            HTMLElement* imgElement = (HTMLElement*)imgNode;
            HTMLElement* descriptionElement = (HTMLElement*)descriptionNode;

            if ( [descriptionElement.tagName isEqualToString:@"div"] && descriptionElement.attributes[@"class"] &&
                [descriptionElement.attributes[@"class"] isEqualToString:@"paragraph"] )
            {
                NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"type": @3, @"src":imgElement.attributes[@"src"], @"description":[descriptionElement serializedFragment]}];
                
                [array addObject:dictionary];
            }
        }
    
    }
}



- (void) parseIMDBSpan:(HTMLElement*)element
{
}


- (void) parseHR
{
    [array addObject:@{@"type":@2}];
}


- (void) parseImageDIV:(HTMLElement*)element
{
    HTMLElement* imgElement = [element firstNodeMatchingSelector:@"img"];
    HTMLElement* descriptionDivElement = [element firstNodeMatchingSelector:@"div"];
    
    if ( imgElement )
    {
        NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"type": @1, @"src":imgElement.attributes[@"src"]}];

        if ( descriptionDivElement )
        {
            NSString* description = [descriptionDivElement.textContent stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            dictionary[@"description"] = description;
        }
        
        [array addObject:dictionary];
    }
}


- (void) parseTextDIV:(HTMLElement*)element
{
    [array addObject:@{@"type":@0, @"description":[element serializedFragment]}];
}






- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

@end
