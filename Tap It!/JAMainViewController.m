//
//  JAMainViewController.m
//  Tap It!
//
//  Created by Jacob Andersson on 07/02/15.
//  Copyright (c) 2015 Jacob Andersson. All rights reserved.
//

#import "JAMainViewController.h"
#import "JATapGame.h"
#import "JATileGridCollectionViewCell.h"
#import "JATile.h"
#import "UIColor+TapIt.h"

static NSString * const kCellIdentifier = @"kTileGridCell";

@interface JAMainViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) JATapGame *gameModel;
@property (nonatomic, strong) UICollectionView * tileGrid;
@property (nonatomic, strong) NSMutableArray * tiles;
@property (nonatomic, strong) UIButton *startStopButton;
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *highScoreLabel;
@property (nonatomic, strong) UIView *tapColorView;
@property (nonatomic, strong) CAGradientLayer *tileVariantGradient;
@property (nonatomic, strong) UISegmentedControl *gameModePicker;

@end

@implementation JAMainViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor mainViewBackgroundColor];
    
    self.highScoreLabel = [UILabel new];
    self.highScoreLabel.translatesAutoresizingMaskIntoConstraints = false;
    self.highScoreLabel.textColor = [UIColor yellowTextColor];
    self.highScoreLabel.textAlignment = NSTextAlignmentCenter;
    
    UIView *topPanel = [UIView new];
    topPanel.translatesAutoresizingMaskIntoConstraints = false;
    topPanel.backgroundColor = [UIColor topPanelBackgroundColor];
    
    UIView *gridPanel = [UIView new];
    gridPanel.translatesAutoresizingMaskIntoConstraints = false;
    [gridPanel.layer addSublayer:[JAMainViewController shadowGradientForFrame:self.view.bounds]];
    
    UIView *bottomPanel = [UIView new];
    bottomPanel.translatesAutoresizingMaskIntoConstraints = false;
    bottomPanel.backgroundColor = [UIColor bottomPanelBackgroundColor];
    [bottomPanel.layer addSublayer:[JAMainViewController shadowGradientForFrame:self.view.bounds]];
    
    UILabel *timeLabel = [UILabel new];
    timeLabel.translatesAutoresizingMaskIntoConstraints = false;
    timeLabel.textColor = [UIColor yellowTextColor];
    timeLabel.text = @"Time: ";
    
    self.currentTimeLabel = [UILabel new];
    self.currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false;
    self.currentTimeLabel.textColor = [UIColor yellowTextColor];
    
    self.tapColorView = [UIView new];
    self.tapColorView.translatesAutoresizingMaskIntoConstraints = false;
    self.tapColorView.layer.cornerRadius = 4.0;
    self.tapColorView.layer.borderColor = [UIColor blackColor].CGColor;
    self.tapColorView.layer.borderWidth = 1.0;
    self.tapColorView.layer.masksToBounds = YES;
    
    self.tileVariantGradient = [CAGradientLayer layer];
    self.tileVariantGradient.colors = [JATile gradientColorsForTileVariant:TileVariantTapped];
    [self.tapColorView.layer addSublayer:self.tileVariantGradient];
    
    self.gameModePicker = [[UISegmentedControl alloc] initWithItems:@[@"Newbie", @"Pro"]];
    self.gameModePicker.translatesAutoresizingMaskIntoConstraints = false;
    [self.gameModePicker setSelectedSegmentIndex:0];
    [self.gameModePicker addTarget:self action:@selector(toggleGameMode) forControlEvents:UIControlEventValueChanged];
    self.gameModePicker.tintColor = [UIColor yellowTextColor];
    
    int screenWidth = [[UIScreen mainScreen] bounds].size.width;
    int tileSpacing = 10;
    int sideMargin = 20;
    int tileSize = (screenWidth - 2*sideMargin - 2*tileSpacing) / 3;
    int gridWidth = 3*tileSize + 2*tileSpacing;
    
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(tileSize, tileSize);
    flowLayout.minimumInteritemSpacing = tileSpacing;
    flowLayout.minimumLineSpacing = tileSpacing;
    
    self.tileGrid = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [self.tileGrid registerClass:JATileGridCollectionViewCell.class forCellWithReuseIdentifier:kCellIdentifier];
    self.tileGrid.dataSource = self;
    self.tileGrid.delegate = self;
    self.tileGrid.translatesAutoresizingMaskIntoConstraints = false;
    self.tileGrid.backgroundColor = [UIColor clearColor];
    [self.tileGrid.viewForBaselineLayout.layer setSpeed:1.5f];
    
    self.startStopButton = [UIButton new];
    self.startStopButton.translatesAutoresizingMaskIntoConstraints = false;
    [self.startStopButton setTitleColor:[UIColor yellowTextColor] forState:UIControlStateNormal];
    [self.startStopButton setTitle:@"Start" forState:UIControlStateNormal];
    [self.startStopButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:24]];
    [self.startStopButton addTarget:self action:@selector(toggleGameState) forControlEvents:UIControlEventTouchUpInside];
    
    [topPanel addSubview:timeLabel];
    [topPanel addSubview:self.currentTimeLabel];
    [topPanel addSubview:self.tapColorView];
    [gridPanel addSubview:self.gameModePicker];
    [gridPanel addSubview:self.tileGrid];
    [gridPanel addSubview:self.highScoreLabel];
    [bottomPanel addSubview:self.startStopButton];
    
    [self.view addSubview:topPanel];
    [self.view addSubview:gridPanel];
    [self.view addSubview:bottomPanel];
    
    //Dropping visual support for crappy old iPhones (4/4s) :)
    //iPads and newer iPhones are however accounted for
    
    NSDictionary * metrics = @{@"standardMargin": @(sideMargin),
                               @"labelWidth": @(50),
                               @"labelHeight": @(20),
                               @"topMargin": @(40),
                               @"currentColorSize": @(20),
                               @"gameModePickerHeight": @(30),
                               @"bottomPanelHeight": @(75)};

    NSDictionary * views = @{@"topPanel": topPanel,
                             @"gridPanel": gridPanel,
                             @"timeLabel": timeLabel,
                             @"currentTimeLabel": self.currentTimeLabel,
                             @"currentColor": self.tapColorView,
                             @"tileGrid": self.tileGrid,
                             @"highScoreLabel": self.highScoreLabel,
                             @"bottomPanel": bottomPanel,
                             @"gameModePicker": self.gameModePicker,
                             @"startStopButton": self.startStopButton};
    
    [topPanel addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(standardMargin)-[timeLabel(labelWidth)][currentTimeLabel(labelWidth)]-(>=0)-[currentColor(currentColorSize)]-(standardMargin)-|"
                                             options:0
                                             metrics:metrics
                                               views:views]];
    
    [topPanel addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(topMargin)-[timeLabel(labelHeight)]-(standardMargin)-|"
                                             options:0
                                             metrics:metrics
                                               views:views]];
    
    [topPanel addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(topMargin)-[currentTimeLabel(labelHeight)]-(standardMargin)-|"
                                             options:0
                                             metrics:metrics
                                               views:views]];
    
    [topPanel addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(topMargin)-[currentColor(labelHeight)]-(standardMargin)-|"
                                             options:0
                                             metrics:metrics
                                               views:views]];
    
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topPanel]|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    [gridPanel addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[highScoreLabel]|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    [gridPanel addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(standardMargin)-[gameModePicker(gameModePickerHeight)]"
                                             options:0
                                             metrics:metrics
                                               views:views]];
    
    [gridPanel addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:[highScoreLabel]-(standardMargin)-|"
                                             options:0
                                             metrics:metrics
                                               views:views]];
    
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[gridPanel]|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    [bottomPanel addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[startStopButton]|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    [bottomPanel addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[startStopButton]|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomPanel]|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topPanel][gridPanel][bottomPanel(bottomPanelHeight)]|"
                                             options:0
                                             metrics:metrics
                                               views:views]];
    
    [gridPanel addConstraint:
     [NSLayoutConstraint constraintWithItem:self.gameModePicker
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:gridPanel
                                  attribute:NSLayoutAttributeCenterX
                                 multiplier:1.0
                                   constant:0]];
    
    [gridPanel addConstraint:
     [NSLayoutConstraint constraintWithItem:self.tileGrid
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1.0
                                   constant:gridWidth]];
    
    [gridPanel addConstraint:
     [NSLayoutConstraint constraintWithItem:self.tileGrid
                                  attribute:NSLayoutAttributeWidth
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1.0
                                   constant:gridWidth]];
    
    [gridPanel addConstraint:
     [NSLayoutConstraint constraintWithItem:self.tileGrid
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:gridPanel
                                  attribute:NSLayoutAttributeCenterX
                                 multiplier:1.0
                                   constant:0]];
    
    [gridPanel addConstraint:
     [NSLayoutConstraint constraintWithItem:self.tileGrid
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:gridPanel
                                  attribute:NSLayoutAttributeCenterY
                                 multiplier:1.0
                                   constant:5]];
    
    //Listen to updates from game model, take care of updates in method modelUpdated
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modelUpdated:) name:kTapGameUpdateEvent object:nil];
    self.gameModel = [JATapGame new];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (CGRectEqualToRect(self.tileVariantGradient.frame, CGRectZero)) {
        self.tileVariantGradient.frame = self.tapColorView.bounds;
    }
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //Make sure timers are invalidated when view goes away
    [self.gameModel stopGame];
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private methods

- (void) toggleGameState
{
    [self.gameModel toggleGameState];
}

- (void) toggleGameMode
{
    [self.gameModel toggleGameMode];
}

- (void) modelUpdated:(NSNotification *) notification
{
    NSDictionary *info = [notification userInfo];
    NSEnumerator *enumerator = [info keyEnumerator];
    id key;
    
    //Iterate over all keys in the NSDictionary sent by the game model
    while ((key = [enumerator nextObject])) {
        id message = info[key];
        
        //Update view depending on the UpdateEvent that has occured
        switch ((GameEvent)[key intValue]) {
            case GameEventStart:
                [self.gameModePicker setEnabled:false];
                [self updateStartStopButtonTitle:message];
                break;
            case GameEventStop:
                [self.gameModePicker setEnabled:true];
                [self updateStartStopButtonTitle:message];
                break;
            case GameEventTimeTick:
                [self updateTime:message];
                break;
            case GameEventLoadHighScore:
                [self updateHighScore:message alert:false];
                break;
            case GameEventNewHighScore:
                [self updateHighScore:message alert:true];
                break;
            case GameEventNewTileVariant:
                [self updateCurrentTileVariant:message];
                break;
            case GameEventTilesReady:
                self.tiles = [NSMutableArray arrayWithArray:message];
                [self.tileGrid reloadData];
                break;
            case GameEventTilesShuffled:
                [self shuffleTiles:message];
                break;
            case GameEventTileTapped:
                [self tileTappedAtIndex:message];
                break;
            default:
                NSLog(@"Too bad, something went wrong o_O");
                break;
        }
    }
}

- (void) updateHighScore:(NSString *) highScore alert:(BOOL) alert
{
    self.highScoreLabel.text = [NSString stringWithFormat:@"High score: %@", highScore];
    
    if (alert) {
        [[[UIAlertView alloc] initWithTitle:@"^^"
                                    message:@"High Score!"
                                   delegate:nil
                          cancelButtonTitle:@"Hell yeah!"
                          otherButtonTitles:nil] show];
    }
}

- (void) shuffleTiles:(NSArray *) shuffledTiles
{
    [self.tileGrid performBatchUpdates:^{
        NSArray *oldTiles = self.tiles.copy;
        [self.tiles removeAllObjects];
        [self.tiles addObjectsFromArray:shuffledTiles];
        
        for (NSInteger i = 0; i < oldTiles.count; i++) {
            NSIndexPath *fromIndexPath = [NSIndexPath indexPathForItem:i inSection:0];
            NSInteger j = [self.tiles indexOfObject:oldTiles[i]];
            NSIndexPath *toIndexPath = [NSIndexPath indexPathForItem:j inSection:0];
            [self.tileGrid moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
        }
    } completion:nil];
}

- (void) updateCurrentTileVariant:(NSNumber *) tileVariant
{
    self.tileVariantGradient.colors = [JATile gradientColorsForTileVariant:tileVariant.intValue];
}

- (void) tileTappedAtIndex:(NSNumber *) index
{
    JATile *tile = self.tiles[index.intValue];
    tile.tapped = YES;
    [self.tileGrid reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index.intValue inSection:0]]];
}

- (void) updateStartStopButtonTitle:(NSString *) title
{
    [self.startStopButton setTitle:title forState:UIControlStateNormal];
}

- (void) updateTime:(NSString *) time
{
    self.currentTimeLabel.text = time;
}


#pragma mark - UICollectionViewDelegate/UICollectionViewDataSource methods

- (NSInteger) collectionView:(UICollectionView *) collectionView numberOfItemsInSection:(NSInteger) section
{
    return self.tiles.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *) collectionView cellForItemAtIndexPath:(NSIndexPath *) indexPath
{
    JATileGridCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    JATile *tile = self.tiles[indexPath.item];
    [cell applyGradientWithColors:[JATile gradientColorsForTileVariant:tile.variant]];
    
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.gameModel tileTapped:indexPath.item];
}


#pragma mark - Static helper methods

+ (CAGradientLayer *) shadowGradientForFrame:(CGRect) frame
{
    CAGradientLayer *shadowGradient = [CAGradientLayer layer];
    shadowGradient.frame = CGRectMake(0, 0, frame.size.width, 10);
    shadowGradient.colors = @[(id)[UIColor colorWithWhite:0.0 alpha:0.25f].CGColor, (id)[UIColor clearColor].CGColor];
    
    return shadowGradient;
}

@end
