//
//  UINavigationBar+CustomHeight.m
//

#import "UINavigationBar+CustomHeight.h"
#import "objc/runtime.h"

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
    return YES;
}


- (void)navigationBar:(UINavigationBar *)navigationBar didPushItem:(UINavigationItem *)item;    // called at end of animation of push or
{
    VFSNavigationBarHeightIncrease = 0.f;
    
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    if ( navigationBar.items.count == 2 )
        VFSNavigationBarHeightIncrease = 30.f;
    
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
