//
//  UINavigationBar+CustomHeight.m
//
//  Copyright (c) 2014 Maciej Swic
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "UINavigationBar+CustomHeight.h"
#import "objc/runtime.h"

//const CGFloat VFSNavigationBarHeightIncrease = 38.f;

@implementation VFSNavigationBar

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self )
    {
        [self initialize];
        VFSNavigationBarHeightIncrease = 30.f;
        self.delegate = self;
    }
    return self;
}

//- (CGSize)sizeThatFits:(CGSize)size {
//    
//    CGSize amendedSize = [super sizeThatFits:size];
//    amendedSize.height += VFSNavigationBarHeightIncrease;
//    
//    return amendedSize;
//}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSArray *classNamesToReposition = @[@"_UINavigationBarBackground"];
    for (UIView *view in [self subviews]) {
        
        if ([classNamesToReposition containsObject:NSStringFromClass([view class])]) {
            
            CGRect bounds = [self bounds];
            CGRect frame = [view frame];
            frame.origin.y = bounds.origin.y + VFSNavigationBarHeightIncrease-50.f;
            frame.size.height = bounds.size.height + 50.f;
            
            [view setFrame:frame];
        }
    }
}


- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item
{
    VFSNavigationBarHeightIncrease = 0.f;
    
//    [UIView animateWithDuration:0.2 animations:^{
//        
//        NSArray *classNamesToReposition = @[@"_UINavigationBarBackground"];
//        for (UIView *view in [self subviews]) {
//            
//            if ([classNamesToReposition containsObject:NSStringFromClass([view class])]) {
//                
//                CGRect bounds = [self bounds];
//                CGRect frame = [view frame];
//                frame.origin.y = bounds.origin.y-50.f;
//                frame.size.height = bounds.size.height + 50.f;
//                
//                [view setFrame:frame];
//            }
//        }
//        
//    }];
    
    return YES;
}


- (void)navigationBar:(UINavigationBar *)navigationBar didPushItem:(UINavigationItem *)item;    // called at end of animation of push or
{
    VFSNavigationBarHeightIncrease = 0.f;
    
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
//    NSLog(@"2 %lu", (unsigned long)navigationBar.items.count);
    VFSNavigationBarHeightIncrease = 30.f;
    
//    [self sizeToFit];
    
    return YES;
}


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (void)initialize {
    
    [self setTransform:CGAffineTransformMakeTranslation(0, -(VFSNavigationBarHeightIncrease))];
}


@end
