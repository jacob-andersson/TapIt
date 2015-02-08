//
//  JATapGame.h
//  Tap It!
//
//  Created by Jacob Andersson on 07/02/15.
//  Copyright (c) 2015 Jacob Andersson. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kTapGameUpdateEvent = @"kTapGameUpdateEvent";
static int const kTapGameNrOfTiles = 9;
static int const kTapGameNrOfTileVariants = 3;

typedef NS_ENUM(NSInteger, GameEvent) {
    GameEventStart,
    GameEventStop,
    GameEventTime,
    GameEventLoadHighScore,
    GameEventNewHighScore,
    GameEventCurrentColor,
    GameEventInitTiles,
    GameEventShuffleTiles,
    GameEventDisableButton
};

typedef NS_ENUM(NSInteger, GameMode) {
    GameModeEasy,
    GameModeHard
};

@interface JATapGame : NSObject

- (void) toggleGameState;

- (void) toggleGameMode;

- (void) tileTapped:(NSUInteger)index;

@end
