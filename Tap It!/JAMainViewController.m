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
    
    //Listen to updates from game model, take care of updates in method modelUpdated
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modelUpdated:) name:kTapGameUpdateEvent object:nil];
    
    self.gameModel = [JATapGame new];
    
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
    
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(90.0, 90.0);
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.minimumLineSpacing = 10;
    
    self.tileGrid = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [self.tileGrid registerClass:JATileGridCollectionViewCell.class forCellWithReuseIdentifier:kCellIdentifier];
    self.tileGrid.dataSource = self;
    self.tileGrid.delegate = self;
    self.tileGrid.translatesAutoresizingMaskIntoConstraints = false;
    self.tileGrid.backgroundColor = [UIColor clearColor];
    [self.tileGrid.viewForBaselineLayout.layer setSpeed:1.5f];
    
    self.gameModePicker = [[UISegmentedControl alloc] initWithItems:@[@"Newbie", @"Pro"]];
    self.gameModePicker.translatesAutoresizingMaskIntoConstraints = false;
    [self.gameModePicker setSelectedSegmentIndex:0];
    [self.gameModePicker addTarget:self action:@selector(toggleGameMode) forControlEvents:UIControlEventValueChanged];
    self.gameModePicker.tintColor = [UIColor yellowTextColor];
    
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
    [bottomPanel addSubview:self.startStopButton];
    
    [self.view addSubview:topPanel];
    [self.view addSubview:gridPanel];
    [self.view addSubview:bottomPanel];
    
    NSDictionary * views = @{@"topPanel": topPanel,
                             @"gridPanel": gridPanel,
                             @"timeLabel": timeLabel,
                             @"currentTimeLabel": self.currentTimeLabel,
                             @"currentColor": self.tapColorView,
                             @"tileGrid": self.tileGrid,
                             @"bottomPanel": bottomPanel,
                             @"gameModePicker": self.gameModePicker,
                             @"startStopButton": self.startStopButton};
    
    [topPanel addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-30-[timeLabel(50)][currentTimeLabel(50)]-(>=0)-[currentColor(20)]-30-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    [topPanel addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[timeLabel(20)]-20-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    [topPanel addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[currentTimeLabel(20)]-20-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    [topPanel addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[currentColor(20)]-20-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topPanel]|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    [gridPanel addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-75-[gameModePicker]-75-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    [gridPanel addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[gameModePicker(30)]"
                                             options:0
                                             metrics:nil
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
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topPanel][gridPanel][bottomPanel(75)]|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    [gridPanel addConstraint:
     [NSLayoutConstraint constraintWithItem:self.tileGrid
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1.0
                                   constant:290]];
    
    [gridPanel addConstraint:
     [NSLayoutConstraint constraintWithItem:self.tileGrid
                                  attribute:NSLayoutAttributeWidth
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:1.0
                                   constant:290]];
    
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
                                   constant:30]];
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
        id message = [info objectForKey:key];
        
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
    self.highScoreLabel.text = highScore;
    
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
