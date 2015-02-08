//
//  JATileGridCollectionViewCell.h
//  Tap It!
//
//  Created by Jacob Andersson on 07/02/15.
//  Copyright (c) 2015 Jacob Andersson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JATileGridCollectionViewCell : UICollectionViewCell

- (void) setDefaultGradient;
- (void) updateGradientWithStartColor:(UIColor *) startColor andEndColor:(UIColor *) endColor;

@end
