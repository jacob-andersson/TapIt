//
//  JATile.m
//  Tap It!
//
//  Created by Jacob Andersson on 08/02/15.
//  Copyright (c) 2015 Jacob Andersson. All rights reserved.
//

#import "JATile.h"
#import "UIColor+TapIt.h"

@implementation JATile

- (instancetype) initTileWithVariant:(TileVariant) variant
{
    self = [super init];
    if (self) {
        self.variant = variant;
    }
    return self;
}

+ (NSArray *) gradientColorsForTileVariant:(TileVariant) variant
{
    NSArray * gradientColors;
    
    switch (variant) {
        case TileVariantPurple:
            gradientColors = @[(id)[UIColor lightPurpuleColor].CGColor,(id)[UIColor darkPurpuleColor].CGColor];
            break;
        case TileVariantYellow:
            gradientColors = @[(id)[UIColor lightYellowColor].CGColor,(id)[UIColor darkYellowColor].CGColor];
            break;
        case TileVariantOrange:
            gradientColors = @[(id)[UIColor lightOrangeColor].CGColor,(id)[UIColor darkOrangeColor].CGColor];
            break;
        case TileVariantTapped:
            gradientColors = @[(id)[UIColor lightTappedColor].CGColor,(id)[UIColor darkTappedColor].CGColor];
            break;
        default:
            gradientColors = @[(id)[UIColor whiteColor].CGColor,(id)[UIColor blackColor].CGColor];
            break;
    }
    
    return gradientColors;
}

@end