//
//  HTMLConvertOperation.m
//  Weird Retro
//
//  Created by User i7 on 03/02/15.
//  Copyright (c) 2015 Alex Dougas. All rights reserved.
//

#import "HTMLConvertOperation.h"
#import "HTMLReader.h"
#import "HTMLParser.h"


@interface HTMLConvertOperation ()
{
    BOOL started;
    NSMutableArray* array;
    NSMutableArray* arraySkip;
}

@property (nonatomic, strong) HTMLDocument* htmlDocument;

@end



@implementation HTMLConvertOperation


- (void)main
{
    if ( !self.htmlMarkup || self.htmlMarkup.length == 0 )
        return;
    
    array = [NSMutableArray new];
    arraySkip = [NSMutableArray new];
    
    self.htmlDocument = [HTMLDocument documentWithString:self.htmlMarkup];

    HTMLElement* elementContent = [self.htmlDocument firstNodeMatchingSelector:@"[id=\"wsite-content\"]"];
    
    if ( self.type == 0 )
        [self startParsingTheMemory:elementContent];
    else if ( self.type == 1 )
        [self startParsingThePost:elementContent];
    
    if ( self.successFailureBlock )
        self.successFailureBlock(array);
}

//////////////

- (void) parsingMenuBar
{
//    NSArray* menuItems = [self.htmlDocument nodesMatchingSelector:@"ul[class='wsite-menu']>li>a"];
}




- (void) startParsingThePost:(HTMLElement*)contentElement
{
    for (HTMLNode* childrenNode in contentElement.children)
    {
        [self parseNode:childrenNode level:0];
    }
    
    // Remove separator isf it's last
    if ( [[array lastObject][@"type"] integerValue] == 2 )
        [array removeLastObject];
}


- (void) startParsingTheMemory:(HTMLElement*)contentElement
{
    for (HTMLNode* childrenNode in contentElement.children)
    {
        [self parseNode:childrenNode level:0];
    }
    
    
    
    [array filterUsingPredicate:[NSPredicate predicateWithFormat:@"type = %@", @3]];
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
        else if ( [element.tagName isEqualToString:@"h2"] && element.attributes[@"class"] && [element.attributes[@"class"] isEqualToString:@"wsite-content-title"] )
        {
            // OK
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
        HTMLElement* anchorElement = [descriptionElement firstNodeMatchingSelector:@"a"];
        
        
        if ( imgElement && descriptionElement && anchorElement && anchorElement.attributes[@"href"] )
        {
            if ( [descriptionElement.tagName isEqualToString:@"div"] && descriptionElement.attributes[@"class"] &&
                [descriptionElement.attributes[@"class"] isEqualToString:@"paragraph"] )
            {
                NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"type": @3, @"src":imgElement.attributes[@"src"], @"description":descriptionElement.innerHTML, @"link":anchorElement.attributes[@"href"]}];
                
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


- (void) parseSlides
{
    NSError *error = NULL;
    NSRegularExpressionOptions regexOptions = NSRegularExpressionCaseInsensitive;
    
    NSString *pattern = @"wslideshow.render\\(\\{[^\\}]+images:(\\[\\{[^\\]]+\\])";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:regexOptions error:&error];
    if (error)
    {
        NSLog(@"Couldn't create regex with given string and options");
        return;
    }
    
    NSRange textRange = NSMakeRange(0, self.htmlMarkup.length);
    NSTextCheckingResult* matches = [regex firstMatchInString:self.htmlMarkup options:NSMatchingReportProgress range:textRange];
    
    if ( matches.numberOfRanges < 2 || [matches rangeAtIndex:1].location == NSNotFound )
        return;
    
    NSArray* imagesArray = [NSJSONSerialization JSONObjectWithData:[[self.htmlMarkup substringWithRange:[matches rangeAtIndex:1]] dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    
    if ( error || !imagesArray || imagesArray.count == 0 )
        return;
    
    NSDictionary* dictionary = @{@"type": @4, @"images":imagesArray};
    [array addObject:dictionary];
}


- (void) parseHR
{
    if ( [[array lastObject][@"type"] integerValue] != 2 )
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





@end
