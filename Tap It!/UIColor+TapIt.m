//
//  UIColor+TapIt.m
//  Tap It!
//
//  Created by Jacob Andersson on 08/02/15.
//  Copyright (c) 2015 Jacob Andersson. All rights reserved.
//

#import "UIColor+TapIt.h"

@implementation UIColor (TapIt)

#pragma mark - Main view colors

+ (UIColor *) mainViewBackgroundColor
{
    return [UIColor colorWithRed:40.0/255.0 green:40.0/255.0 blue:45.0/255.0 alpha:1.0];
}

+ (UIColor *) topPanelBackgroundColor
{
    return [UIColor colorWithRed:40.0/255.0 green:40.0/255.0 blue:45.0/255.0 alpha:0.5];
}

+ (UIColor *) bottomPanelBackgroundColor
{
    return [UIColor colorWithRed:35.0/255.0 green:35.0/255.0 blue:40.0/255.0 alpha:1.0];
}

+ (UIColor *) yellowTextColor
{
    return [UIColor colorWithRed:225.0/255.0 green:180.0/255.0 blue:100.0/255.0 alpha:1.0];
}


#pragma mark - Tile colors

+ (UIColor *) lightPurpuleColor
{
    return [UIColor colorWithRed:160.0/255.0 green:80.0/255.0 blue:120.0/255.0 alpha:1.0];
}

+ (UIColor *) darkPurpuleColor
{
    return [UIColor colorWithRed:110.0/255.0 green:55.0/255.0 blue:85.0/255.0 alpha:1.0];
}

+ (UIColor *) lightYellowColor
{
    return [UIColor colorWithRed:200.0/255.0 green:160.0/255.0 blue:95.0/255.0 alpha:1.0];
}

+ (UIColor *) darkYellowColor
{
    return [UIColor colorWithRed:145.0/255.0 green:115.0/255.0 blue:70.0/255.0 alpha:1.0];
}

+ (UIColor *) lightOrangeColor
{
    return [UIColor colorWithRed:190.0/255.0 green:105.0/255.0 blue:90.0/255.0 alpha:1.0];
}

+ (UIColor *) darkOrangeColor
{
    return [UIColor colorWithRed:140.0/255.0 green:80.0/255.0 blue:75.0/255.0 alpha:1.0];
}

+ (UIColor *) lightTappedColor
{
    return [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
}

+ (UIColor *) darkTappedColor
{
    return [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0];
}

@end
