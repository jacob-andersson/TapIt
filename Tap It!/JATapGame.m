//
//  JATapGame.m
//  Tap It!
//
//  Created by Jacob Andersson on 07/02/15.
//  Copyright (c) 2015 Jacob Andersson. All rights reserved.
//

#import "JATapGame.h"
#import "JATile.h"

@interface JATapGame ()

@property (nonatomic, readonly) NSArray *immutableTiles;
@property (nonatomic, strong) NSMutableArray *tiles;
@property (nonatomic, strong) NSTimer *gameTimer;
@property (nonatomic, strong) NSTimer *shuffleTimer;
@property (nonatomic, assign) GameMode activeGameMode;
@property (nonatomic, assign) TileVariant currentTileVariant;
@property (nonatomic, assign) BOOL isGameRunning;
@property (nonatomic, assign) int currentHighScore;
@property (nonatomic, assign) int elapsedTime;
@property (nonatomic, assign) int nrOfTappedTiles;

@end

@implementation JATapGame

- (instancetype) init
{
    self = [super init];
    if (self) {
        self.isGameRunning = false;
        self.elapsedTime = 0;
        self.activeGameMode = GameModeEasy;
        self.nrOfTappedTiles = 0;
        self.gameTimer = [[NSTimer alloc] init];
        self.shuffleTimer = [[NSTimer alloc] init];
        self.tiles = [NSMutableArray arrayWithCapacity:kTapGameNrOfTiles];
        
        //Make sure placeholder tiles are shown before user starts a game
        [self initPlaceholderTiles];
        [self notifyControllerOfUpdate:GameEventTilesReady withObject:self.immutableTiles];
        
        if (self.currentHighScore != 0) {
            [self notifyControllerOfUpdate:GameEventLoadHighScore withObject:[self displayTime:self.currentHighScore]];
        }
    }
    return self;
}

#pragma mark - Public metods

- (void) tileTapped:(NSUInteger) index
{
    if (self.isGameRunning) {
        
        //Only do something if a button with correct color was pressed
        JATile * tile = self.tiles[index];
        if (self.currentTileVariant == tile.variant && !tile.isTapped) {
            tile.variant = TileVariantTapped;
            self.nrOfTappedTiles += 1;
            
            //Valid tap updated model, time to propagate the update
            [self notifyControllerOfUpdate:GameEventTileTapped withObject:[NSNumber numberWithInteger:index]];
            
            //End game and check highscore if the last button of the correct color was pressed
            if (self.nrOfTappedTiles == kTapGameNrOfTileVariants) {
                int gameTime = self.elapsedTime;
                [self stopGame];
                [self checkHighScore: gameTime];
            }
        }
    }
}

- (void) toggleGameState
{
    if (self.isGameRunning) {
        [self stopGame];
    } else {
        [self startGame];
    }
}

- (void) toggleGameMode
{
    self.activeGameMode = self.activeGameMode == GameModeEasy ? GameModeHard : GameModeEasy;
    NSString *message = [self displayTime:self.currentHighScore];
    [self notifyControllerOfUpdate:GameEventLoadHighScore withObject:message];
}


#pragma mark - Private metods

- (NSArray *) immutableTiles
{
    if (self.tiles) {
        return self.tiles.copy;
    }
    
    return nil;
}

- (int) currentHighScore
{
    //TODO: read from NSUserDefault using activeGameMode as key
    return 0;
}

- (void) initPlaceholderTiles
{
    for (int i = 0; i < kTapGameNrOfTiles; i++) {
        JATile *tile = [[JATile alloc] initTileWithVariant:TileVariantTapped];
        [self.tiles addObject:tile];
    }
}

- (void) refreshTilesArray
{
    for (int i = 0; i < kTapGameNrOfTiles; i++) {
        JATile *tile = self.tiles[i];
        tile.variant = i%kTapGameNrOfTileVariants;
        tile.tapped = NO;
    }
    
    [self shuffleTiles];
}

- (void) startGame
{
    [self decideTileVariant];
    [self refreshTilesArray];
    
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                      target:self
                                                    selector:@selector(clockEvent)
                                                    userInfo:nil
                                                     repeats:YES];
    
    //When game mode is set to hard, start another timer (used to re-shuffle the buttons)
    if (self.activeGameMode == GameModeHard) {
        self.shuffleTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                             target:self
                                                           selector:@selector(shuffleEvent)
                                                           userInfo:nil
                                                            repeats:YES];
    }
    
    self.isGameRunning = true;
    
    //Notify controller of model updates
    [self notifyControllerOfUpdate:GameEventNewTileVariant withObject:[NSNumber numberWithInt:self.currentTileVariant]];
    [self notifyControllerOfUpdate:GameEventTilesReady withObject:self.immutableTiles];
    [self notifyControllerOfUpdate:GameEventStart withObject:@"Stop"];
}

- (void) stopGame
{
    [self.gameTimer invalidate];
    [self.shuffleTimer invalidate];
    self.elapsedTime = 0;
    self.nrOfTappedTiles = 0;
    self.isGameRunning = false;
    [self notifyControllerOfUpdate:GameEventStop withObject:@"Start"];
}

- (void) decideTileVariant
{
    self.currentTileVariant = arc4random() % kTapGameNrOfTileVariants;
}

//Shuffle the buttons by swapping places of buttons in the array
- (void) shuffleTiles
{
    for (int i = 0; i < kTapGameNrOfTiles; ++i) {
        NSInteger remainingCount = kTapGameNrOfTiles - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t)remainingCount);
        
        JATile *from = self.tiles[i];
        JATile *to = self.tiles[exchangeIndex];
        
        if (!from.isTapped && !to.isTapped) {
            [self.tiles exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
        }
    }
}

//Check high score depending on game mode and save new highscores by using NSUserDefaults
- (void) checkHighScore:(int) gameTime
{
    if (gameTime < self.currentHighScore || self.currentHighScore == 0) {
        //TODO: Fix custom setter and save to NSUserDefaults
        self.currentHighScore = gameTime;
        [self notifyControllerOfUpdate:GameEventNewHighScore withObject:[self displayTime:self.currentHighScore]];
    }
}

- (void) clockEvent
{
    self.elapsedTime += 1;
    [self notifyControllerOfUpdate:GameEventTimeTick withObject:[self displayTime:self.elapsedTime]];
}

//Reshuffles the buttons already displayed (in game mode hard)
- (void) shuffleEvent
{
    [self shuffleTiles];
    [self notifyControllerOfUpdate:GameEventTilesShuffled withObject:self.immutableTiles];
}

//Create a string representing the elapsed time
- (NSString *) displayTime:(int) time
{
    int minutes = time / (10 * 60);
    int seconds = (time / 10) % 60;
    int tenthsOfSecond = time % 10;
    
    return [NSString stringWithFormat:@"%01d:%02d:%1d", minutes, seconds, tenthsOfSecond];
}

//Post a notification with updates from game model to the default NSNotificationCenter
- (void) notifyControllerOfUpdate:(GameEvent) event withObject:(NSObject *) obj
{
    NSNumber *evt = [NSNumber numberWithInt:event];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: obj, evt, nil];
    NSNotification *note = [NSNotification notificationWithName:kTapGameUpdateEvent object:self userInfo:dict];
    [[NSNotificationCenter defaultCenter] postNotification:note];
}

@end
