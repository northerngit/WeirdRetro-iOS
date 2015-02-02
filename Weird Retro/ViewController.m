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
    NSMutableArray* arraySkip;
    
}


@end

@implementation ViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    NSString *markup = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fantomash" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
    
    array = [NSMutableArray new];
    arraySkip = [NSMutableArray new];
    
    HTMLDocument *document = [HTMLDocument documentWithString:markup];
    HTMLElement* element = [document firstNodeMatchingSelector:@"[id=\"wsite-content\"]"];

    [self startParsing1:element];
    
    
    
    
    
//    // Create a regular expression
//    BOOL isCaseSensitive = [[options objectForKey:kRWSearchCaseSensitiveKey] boolValue];
//    BOOL isWholeWords = [[options objectForKey:kRWSearchWholeWordsKey] boolValue];
    
    NSError *error = NULL;
    NSRegularExpressionOptions regexOptions = NSRegularExpressionCaseInsensitive;
    
    NSString *pattern = @"wslideshow.render\\(\\{[^\\}]+images:(\\[\\{[^\\]]+\\])";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:regexOptions error:&error];
    if (error)
    {
        NSLog(@"Couldn't create regex with given string and options");
    }
    
    NSRange textRange = NSMakeRange(0, markup.length);
    NSTextCheckingResult* matchRange = [regex firstMatchInString:markup options:NSMatchingReportProgress range:textRange];
    NSLog(@"%@", [markup substringWithRange:[matchRange rangeAtIndex:1]]);
    
    
//    NSLog(@"%@", array);
}



- (void) startParsing1:(HTMLElement*)contentElement
{
    for (HTMLNode* childrenNode in contentElement.children)
    {
        [self parseNode:childrenNode level:0];
    }
    
}

- (void) parseNode:(HTMLNode*)node level:(NSInteger)level
{
    if ( [node isKindOfClass:[HTMLElement class]] && ![arraySkip containsObject:node] )
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
                // Video
                else if ( [class isEqualToString:@"wsite-youtube"] )
                {
                    [self parseYoutube:element];
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
}


- (HTMLElement*) getNextElementSibling:(HTMLElement*)element
{
    for (NSUInteger index = [element.parentNode indexOfChild:element]+1; index < element.parentNode.numberOfChildren; index++)
    {
        HTMLNode* node = [element.parentNode childAtIndex:index];
        if ( [node isKindOfClass:[HTMLElement class]])
            return (HTMLElement*)node;
    }
    
    return nil;
}


- (void) parseImagedLink:(HTMLElement*)element
{
    if ( !element.parentElement )
        return;
    
    NSUInteger index = [element.parentElement indexOfChild:element];
    if ( index + 3 > element.parentElement.numberOfChildren )
        return;

    HTMLElement* spanElement = [self getNextElementSibling:element];
    
    if ( spanElement && [spanElement.tagName isEqualToString:@"span"] )
    {
        HTMLElement* imgElement = [spanElement firstNodeMatchingSelector:@"img"];
        HTMLElement* descriptionElement = [self getNextElementSibling:spanElement];
        
        if ( imgElement && descriptionElement )
        {
            if ( [descriptionElement.tagName isEqualToString:@"div"] && descriptionElement.attributes[@"class"] &&
                [descriptionElement.attributes[@"class"] isEqualToString:@"paragraph"] )
            {
                NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"type": @3, @"src":imgElement.attributes[@"src"], @"description":descriptionElement.innerHTML}];
                
                [arraySkip addObject:spanElement];
                [arraySkip addObject:descriptionElement];
                
                [array addObject:dictionary];
            }
        }
    
    }
}


- (void) parseIMDBSpan:(HTMLElement*)element
{
}


- (void) parseYoutube:(HTMLElement*)element
{
    HTMLElement* iframeElement = [element firstNodeMatchingSelector:@"iframe"];
    
    if ( iframeElement )
    {
        NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"type": @4, @"src": iframeElement.attributes[@"src"]}];
        
        [array addObject:dictionary];
    }
}


- (void) parseSlides:(HTMLElement*)element
{
    NSArray* slidesArray = [element nodesMatchingSelector:@"[class='wslide-link-inner2']"];
    
    NSLog(@"%@", slidesArray);
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
    [array addObject:@{@"type":@0, @"description":element.innerHTML}];
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

@end
