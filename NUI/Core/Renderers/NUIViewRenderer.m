//
//  NUIViewRenderer.m
//  NUIDemo
//
//  Created by Tom Benner on 11/24/12.
//  Copyright (c) 2012 Tom Benner. All rights reserved.
//

#import "NUIViewRenderer.h"
#import "UIView+NUI.h"
#import "NUIGraphics.h"

@implementation NUIViewRenderer

+ (void)render:(UIView*)view withClass:(NSString*)className
{
    if ([NUISettings hasProperty:@"background-image" withClass:className]) {
        if ([NUISettings hasProperty:@"background-repeat" withClass:className] && ![NUISettings getBoolean:@"background-repeat" withClass:className]) {
            view.layer.contents = (__bridge id)[NUISettings getImage:@"background-image" withClass:className].CGImage;
        } else {
            [view setBackgroundColor: [NUISettings getColorFromImage:@"background-image" withClass: className]];
        }
    } else if ([NUISettings hasProperty:@"background-color" withClass:className]) {
        [view setBackgroundColor: [NUISettings getColor:@"background-color" withClass: className]];
    }
    if ([NUISettings hasProperty:@"tint-color" withClass:className]) {
        [view setTintColor:[NUISettings getColor:@"tint-color" withClass: className]];
    }

    [self renderSize:view withClass:className];
    [self renderBorder:view withClass:className];
    [self renderGradient:view withClass:className];
    [self renderShadow:view withClass:className];
}

+ (void)render:(UIView *)view withClass:(NSString *)className withSuffix:(NSString*)suffix
{
    if (![suffix isEqualToString:@""]) {
        className = [NSString stringWithFormat:@"%@%@", className, suffix];
    }
    
    [self render:view withClass:className];
}

+ (void)renderBorder:(UIView*)view withClass:(NSString*)className
{
    CALayer *layer = [view layer];
    
    if ([NUISettings hasProperty:@"border-color" withClass:className]) {
        [layer setBorderColor:[[NUISettings getColor:@"border-color" withClass:className] CGColor]];
    }
    
    if ([NUISettings hasProperty:@"border-width" withClass:className]) {
        [layer setBorderWidth:[NUISettings getFloat:@"border-width" withClass:className]];
    }
    
    if ([NUISettings hasProperty:@"corner-radius" withClass:className]) {
        [layer setCornerRadius:[NUISettings getFloat:@"corner-radius" withClass:className]];
        BOOL clip = YES;
        if ([NUISettings hasProperty:@"clip" withClass:className]) {
            clip = [NUISettings getBoolean:@"clip" withClass:className];
        }
        layer.masksToBounds = clip;
    }
}

+ (void)renderShadow:(UIView*)view withClass:(NSString*)className
{
    CALayer *layer = [view layer];
    
    if ([NUISettings hasProperty:@"shadow-radius" withClass:className]) {
        [layer setShadowRadius:[NUISettings getFloat:@"shadow-radius" withClass:className]];
    }
    
    if ([NUISettings hasProperty:@"shadow-offset" withClass:className]) {
        [layer setShadowOffset:[NUISettings getSize:@"shadow-offset" withClass:className]];
    }
    
    if ([NUISettings hasProperty:@"shadow-color" withClass:className]) {
        [layer setShadowColor:[NUISettings getColor:@"shadow-color" withClass:className].CGColor];
    }
    
    if ([NUISettings hasProperty:@"shadow-opacity" withClass:className]) {
        [layer setShadowOpacity:[NUISettings getFloat:@"shadow-opacity" withClass:className]];
    }
}

+ (void)renderSize:(UIView*)view withClass:(NSString*)className
{
    CGFloat height = view.frame.size.height;
    if ([NUISettings hasProperty:@"height" withClass:className]) {
        height = [NUISettings getFloat:@"height" withClass:className];
    }
    
    CGFloat width = view.frame.size.width;
    if ([NUISettings hasProperty:@"width" withClass:className]) {
        width = [NUISettings getFloat:@"width" withClass:className];
    }

    if (height != view.frame.size.height || width != view.frame.size.width) {
        view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, width, height);
    }
}

+ (void)renderGradient:(UIView*)view withClass:(NSString*)className
{
    if ([NUISettings hasProperty:@"background-color-top" withClass:className]) {
        CAGradientLayer *gradientLayer = [NUIGraphics
                                          gradientLayerWithTop:[NUISettings getColor:@"background-color-top" withClass:className]
                                          bottom:[NUISettings getColor:@"background-color-bottom" withClass:className]
                                          frame:view.bounds];
        
        if ([NUISettings hasProperty:@"corner-radius" withClass:className]) {
            [gradientLayer setCornerRadius:[NUISettings getFloat:@"corner-radius" withClass:className]];
            BOOL clip = YES;
            if ([NUISettings hasProperty:@"clip" withClass:className]) {
                clip = [NUISettings getBoolean:@"clip" withClass:className];
            }
            gradientLayer.masksToBounds = clip;
        }
        
        if ([NUISettings hasProperty:@"gradient-start-point" withClass:className]){
            UIOffset startPoint = [NUISettings getOffset:@"gradient-start-point" withClass:className];
            UIOffset endPoint = [NUISettings getOffset:@"gradient-end-point" withClass:className];
            
            gradientLayer.startPoint = CGPointMake(startPoint.horizontal, startPoint.vertical);
            gradientLayer.endPoint = CGPointMake(endPoint.horizontal, endPoint.vertical);
        }
        
        if (view.gradientLayer) {
            [view.layer replaceSublayer:view.gradientLayer with:gradientLayer];
        } else {
//            int backgroundLayerIndex = [view.layer.sublayers count] == 1 ? 0 : 1;
            [view.layer insertSublayer:gradientLayer atIndex:0];
        }
        
        view.gradientLayer = gradientLayer;
    }
}


+ (BOOL)hasShadowProperties:(UIView*)view withClass:(NSString*)className {
    
    BOOL hasAnyShadowProperty = NO;
    for (NSString *property in @[@"shadow-radius", @"shadow-offset", @"shadow-color", @"shadow-opacity"]) {
        hasAnyShadowProperty |= [NUISettings hasProperty:property withClass:className];
    }
    return hasAnyShadowProperty;
}

@end
