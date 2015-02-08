//
//  JATile.h
//  Tap It!
//
//  Created by Jacob Andersson on 08/02/15.
//  Copyright (c) 2015 Jacob Andersson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JATile : NSObject

typedef NS_ENUM(NSInteger, TileVariant) {
    TileVariantPurple,
    TileVariantYellow,
    TileVariantOrange,
    TileVariantTapped
};

@property (nonatomic) TileVariant variant;
@property (nonatomic, getter=isTapped) BOOL tapped;

- (instancetype) initTileWithVariant:(TileVariant) variant;

+ (NSArray *) gradientColorsForTileVariant:(TileVariant) variant;

@end
