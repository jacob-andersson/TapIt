//
//  JATileGridCollectionViewCell.m
//  Tap It!
//
//  Created by Jacob Andersson on 07/02/15.
//  Copyright (c) 2015 Jacob Andersson. All rights reserved.
//

#import "JATileGridCollectionViewCell.h"

@interface JATileGridCollectionViewCell ()

@property (nonatomic, strong) UIView *gradientView;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation JATileGridCollectionViewCell

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaultGradient];
    }
    return self;
}

#pragma mark - Prepare View Components

- (void) setDefaultGradient
{
    if (!self.gradientView) {
        self.gradientView = [UIView new];
        self.gradientView.frame = self.bounds;
        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.frame = self.gradientView.frame;
        self.gradientLayer.startPoint = CGPointMake(0.0, 0.0);
        self.gradientLayer.endPoint = CGPointMake(1.0, 1.0);
        [self.gradientView.layer addSublayer:self.gradientLayer];
        self.gradientView.layer.borderWidth = 1.0;
        self.gradientView.layer.borderColor = [UIColor blackColor].CGColor;
        self.gradientView.layer.cornerRadius = 4.0;
        self.gradientView.clipsToBounds = YES;
        [self addSubview:self.gradientView];
    }
    self.gradientLayer.colors = @[(id)[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0].CGColor,
                                  (id)[UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0].CGColor];
}

- (void) updateGradientWithStartColor:(UIColor *) startColor andEndColor:(UIColor *) endColor
{
    self.gradientLayer.colors = @[(id)startColor.CGColor, (id)endColor.CGColor];
}

@end
