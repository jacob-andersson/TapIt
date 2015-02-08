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

@property (nonatomic, strong) NSMutableArray *tiles;
@property (nonatomic, strong) NSMutableArray *tappedTiles;
@property (nonatomic, strong) NSTimer *gameTimer;
@property (nonatomic, strong) NSTimer *shuffleTimer;
@property (nonatomic) GameMode activeGameMode;
@property (nonatomic) BOOL isGameRunning;
@property (nonatomic) int currentHighScore;
@property (nonatomic) int elapsedTime;
@property (nonatomic) int currentTileVariant;
@property (nonatomic) int nrOfTappedTiles;

@end

@implementation JATapGame

- (instancetype) init {
    self = [super init];
    if (self) {
        self.isGameRunning = false;
        self.elapsedTime = 0;
        self.activeGameMode = GameModeEasy;
        self.nrOfTappedTiles = 0;
        self.tiles = [NSMutableArray arrayWithCapacity:kTapGameNrOfTiles];
        self.gameTimer = [[NSTimer alloc] init];
        self.shuffleTimer = [[NSTimer alloc] init];
        
        if (self.currentHighScore != 0) {
            [self notifyControllerOfUpdate:GameEventLoadHighScore withObject:[self displayTime:self.currentHighScore]];
        }
    }
    return self;
}

#pragma mark - Public metods

- (void) tileTapped:(NSUInteger) index {
    if (self.isGameRunning) {
        
        //Only do something if a button with correct color was pressed
        JATile * tile = [self.tiles objectAtIndex:index];
        if (self.currentTileVariant == tile.variant.intValue && tile.variant.intValue != -1) {
            tile.variant = [NSNumber numberWithInt:-1];
            self.nrOfTappedTiles += 1;
            [self notifyControllerOfUpdate:GameEventDisableButton withObject:[NSNumber numberWithInteger:index]];
            
            //End game and check highscore if the last button of the correct color was pressed
            if (self.nrOfTappedTiles == 3) {
                int gameTime = self.elapsedTime;
                [self stopGame];
                [self checkHighScore: gameTime];
            }
        }
    }
}

- (void) toggleGameState {
    if (self.isGameRunning) {
        [self stopGame];
    } else {
        [self startGame];
    }
}

- (void) toggleGameMode {
    self.activeGameMode = self.activeGameMode == GameModeEasy ? GameModeHard : GameModeEasy;
    NSString *message = [self displayTime:self.currentHighScore];
    [self notifyControllerOfUpdate:GameEventLoadHighScore withObject:message];
}

#pragma mark - Private metods

- (int) currentHighScore
{
    //TODO: read from NSUserDefault using activeGameMode as key
    return 0;
}

- (void) initTilesArray {
    [self.tiles removeAllObjects];
    for (int i = 0; i < kTapGameNrOfTiles; i++) {
        JATile * tile = [JATile new];
        tile.variant = [NSNumber numberWithInt:i%3];
        [self.tiles addObject:tile];
    }
}

- (void) startGame
{
    [self decideTileVariant];
    [self initTilesArray];
    [self shuffleTiles];
    
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(clockEvent) userInfo:nil repeats:YES];
    
    //When game mode is set to hard, start another timer (used to re-shuffle the buttons)
    if (self.activeGameMode == GameModeHard) {
        self.shuffleTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(shuffleEvent) userInfo:nil repeats:YES];
    }
    
    self.isGameRunning = true;
    
    //Create an immutable version to send to controller
    NSArray *tileVariants = [NSArray arrayWithArray:self.tiles];
    
    //Notify controller of model updates
    [self notifyControllerOfUpdate:GameEventCurrentColor withObject:[NSNumber numberWithInt:self.currentTileVariant]];
    [self notifyControllerOfUpdate:GameEventInitTiles withObject:tileVariants];
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
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
        JATile *from = [self.tiles objectAtIndex:i];
        JATile *to = [self.tiles objectAtIndex:exchangeIndex];
        if (from.variant.intValue != -1 && to.variant.intValue != -1) {
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
    [self notifyControllerOfUpdate:GameEventTime withObject:[self displayTime:self.elapsedTime]];
}

//Reshuffles the buttons already displayed (in game mode hard)
- (void) shuffleEvent
{
    [self shuffleTiles];
    NSArray *tileVariants = [NSArray arrayWithArray:self.tiles];
    [self notifyControllerOfUpdate:GameEventShuffleTiles withObject:tileVariants];
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
