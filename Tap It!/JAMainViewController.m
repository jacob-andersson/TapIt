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

static NSString * const kCellIdentifier = @"kTileGridCell";

@interface JAMainViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) JATapGame *gameModel;
@property (nonatomic, strong) UICollectionView * tileGrid;
@property (nonatomic, strong) NSMutableArray * tiles;
@property (nonatomic, strong) NSArray * tileGradients;
@property (nonatomic, strong) UIButton *startStopButton;
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *highScoreLabel;
@property (nonatomic, strong) UIView *tapColorView;
@property (nonatomic, strong) CAGradientLayer *tapColorGradient;
@property (nonatomic, strong) UISegmentedControl *gameModePicker;

@end

@implementation JAMainViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:40.0/255.0 green:40.0/255.0 blue:45.0/255.0 alpha:1.0];
    
    //Register as listener (listen to updates from the game model) and create game instance
    [self registerForNotifications];
    self.gameModel = [JATapGame new];
    
    self.tiles = [[NSMutableArray alloc] initWithCapacity:kTapGameNrOfTiles];
    for (int i = 0; i < kTapGameNrOfTiles; i++) {
        JATile *tile = [JATile new];
        tile.variant = [NSNumber numberWithInt:-1];
        [self.tiles addObject:tile];
    }
    
    self.tileGradients = @[[UIColor colorWithRed:160.0/255.0 green:80.0/255.0 blue:120.0/255.0 alpha:1.0],
                           [UIColor colorWithRed:110.0/255.0 green:55.0/255.0 blue:85.0/255.0 alpha:1.0],
                           [UIColor colorWithRed:200.0/255.0 green:160.0/255.0 blue:95.0/255.0 alpha:1.0],
                           [UIColor colorWithRed:145.0/255.0 green:115.0/255.0 blue:70.0/255.0 alpha:1.0],
                           [UIColor colorWithRed:190.0/255.0 green:105.0/255.0 blue:90.0/255.0 alpha:1.0],
                           [UIColor colorWithRed:140.0/255.0 green:80.0/255.0 blue:75.0/255.0 alpha:1.0]];
    
    UIView *topPanel = [UIView new];
    topPanel.translatesAutoresizingMaskIntoConstraints = false;
    topPanel.backgroundColor = [UIColor colorWithRed:40.0/255.0 green:40.0/255.0 blue:45.0/255.0 alpha:0.5];
    
    UILabel *timeLabel = [UILabel new];
    timeLabel.translatesAutoresizingMaskIntoConstraints = false;
    timeLabel.textColor = [UIColor colorWithRed:225.0/255.0 green:180.0/255.0 blue:100.0/255.0 alpha:1.0];
    timeLabel.text = @"Time: ";
    
    self.currentTimeLabel = [UILabel new];
    self.currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false;
    self.currentTimeLabel.textColor = [UIColor colorWithRed:225.0/255.0 green:180.0/255.0 blue:100.0/255.0 alpha:1.0];
    
    self.tapColorView = [UIView new];
    self.tapColorView.translatesAutoresizingMaskIntoConstraints = false;
    self.tapColorView.layer.cornerRadius = 4.0;
    self.tapColorView.layer.borderColor = [UIColor blackColor].CGColor;
    self.tapColorView.layer.borderWidth = 1.0;
    self.tapColorView.layer.masksToBounds = YES;
    
    self.tapColorGradient = [CAGradientLayer layer];
    self.tapColorGradient.colors = @[(id)[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0].CGColor,
                                     (id)[UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0].CGColor];
    [self.tapColorView.layer addSublayer:self.tapColorGradient];
    
    UIView *gridPanel = [UIView new];
    gridPanel.translatesAutoresizingMaskIntoConstraints = false;
    CAGradientLayer *topShadow = [CAGradientLayer layer];
    topShadow.frame = CGRectMake(0, 0, self.view.bounds.size.width, 10);
    topShadow.colors = @[(id)[UIColor colorWithWhite:0.0 alpha:0.25f].CGColor, (id)[UIColor clearColor].CGColor];
    [gridPanel.layer insertSublayer:topShadow atIndex:0];
    
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(90.0, 90.0);
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.minimumLineSpacing = 10;
    self.tileGrid = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    self.tileGrid.dataSource = self;
    self.tileGrid.delegate = self;
    
    [self.tileGrid registerClass:JATileGridCollectionViewCell.class forCellWithReuseIdentifier:kCellIdentifier];
    self.tileGrid.translatesAutoresizingMaskIntoConstraints = false;
    self.tileGrid.backgroundColor = [UIColor clearColor];
    
    [self.tileGrid.viewForBaselineLayout.layer setSpeed:1.5f];
    
    UIView *bottomPanel = [UIView new];
    bottomPanel.translatesAutoresizingMaskIntoConstraints = false;
    bottomPanel.backgroundColor = [UIColor colorWithRed:35.0/255.0 green:35.0/255.0 blue:40.0/255.0 alpha:1.0];
    topShadow = [CAGradientLayer layer];
    topShadow.frame = CGRectMake(0, 0, self.view.bounds.size.width, 10);
    topShadow.colors = @[(id)[UIColor colorWithWhite:0.0 alpha:0.25f].CGColor, (id)[UIColor clearColor].CGColor];
    [bottomPanel.layer addSublayer:topShadow];
    
    self.gameModePicker = [[UISegmentedControl alloc] initWithItems:@[@"Newbie", @"Pro"]];
    self.gameModePicker.translatesAutoresizingMaskIntoConstraints = false;
    [self.gameModePicker setSelectedSegmentIndex:0];
    [self.gameModePicker addTarget:self action:@selector(toggleGameMode) forControlEvents:UIControlEventValueChanged];
    self.gameModePicker.tintColor = [UIColor colorWithRed:225.0/255.0 green:180.0/255.0 blue:100.0/255.0 alpha:1.0];
    
    self.startStopButton = [UIButton new];
    self.startStopButton.translatesAutoresizingMaskIntoConstraints = false;
    [self.startStopButton setTitleColor:[UIColor colorWithRed:225.0/255.0 green:180.0/255.0 blue:100.0/255.0 alpha:1.0] forState:UIControlStateNormal];
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
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (CGRectEqualToRect(self.tapColorGradient.frame, CGRectZero)) {
        self.tapColorGradient.frame = self.tapColorView.bounds;
    }
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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

- (void) registerForNotifications
{
    //Listen to updates from game model, take care of updates in method modelUpdated
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modelUpdated:) name:kTapGameUpdateEvent object:nil];
}

- (void) modelUpdated:(NSNotification *) notification
{
    //Update received from game model
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
            case GameEventTime:
                [self updateTime:message];
                break;
            case GameEventLoadHighScore:
                [self updateHighScore:message alert:false];
                break;
            case GameEventNewHighScore:
                [self updateHighScore:message alert:true];
                break;
            case GameEventCurrentColor:
                [self updateCurrentColor:message];
                break;
            case GameEventInitTiles:
                [self.tiles removeAllObjects];
                [self.tiles addObjectsFromArray:message];
                [self.tileGrid reloadData];
                break;
            case GameEventShuffleTiles:
                [self shuffleTiles:message];
                break;
            case GameEventDisableButton:
                [self disableButton:message];
                break;
            default:
                NSLog(@"Something went wrong!");
                //Possible termination of program here
                break;
        }
    }
}

- (void) updateHighScore:(NSString *) highScore alert:(BOOL) alert
{
    self.highScoreLabel.text = highScore;
    
    if (alert) {
        [[[UIAlertView alloc] initWithTitle:@"o_O"
                                    message:@"High Score!"
                                   delegate:nil
                          cancelButtonTitle:@"Hell yeah!"
                          otherButtonTitles:nil] show];
    }
}

- (void) shuffleTiles:(NSArray *) shuffledTiles
{
    [self.tileGrid performBatchUpdates:^{
        NSArray *oldTiles = [NSArray arrayWithArray:self.tiles];
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

- (void) updateCurrentColor:(NSNumber *) tileVariant
{
    UIColor *startColor = self.tileGradients[tileVariant.intValue*2];
    UIColor *endColor = self.tileGradients[(tileVariant.intValue*2)+1];
    self.tapColorGradient.colors = @[(id)startColor.CGColor, (id)endColor.CGColor];
}

- (void) disableButton:(NSNumber *) index
{
    JATile *tile = self.tiles[index.intValue];
    tile.variant = [NSNumber numberWithInt:-1];
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


#pragma mark - UICollectionViewDelegate / DataSource methods

- (NSInteger) collectionView:(UICollectionView *) collectionView numberOfItemsInSection:(NSInteger) section
{
    return kTapGameNrOfTiles;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *) collectionView cellForItemAtIndexPath:(NSIndexPath *) indexPath
{
    JATileGridCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    JATile *tile = [self.tiles objectAtIndex:indexPath.item];
    if (tile.variant.intValue == -1) {
        [cell setDefaultGradient];
    } else {
        int c = tile.variant.intValue;
        UIColor *startColor = [self.tileGradients objectAtIndex:c*2];
        UIColor *endColor = [self.tileGradients objectAtIndex:(c*2)+1];
        [cell updateGradientWithStartColor:startColor andEndColor:endColor];
    }
    
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.gameModel tileTapped:indexPath.item];
}

@end
