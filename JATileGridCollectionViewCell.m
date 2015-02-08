//
//  JATileGridCollectionViewCell.m
//  Tap It!
//
//  Created by Jacob Andersson on 07/02/15.
//  Copyright (c) 2015 Jacob Andersson. All rights reserved.
//

#import "JATileGridCollectionViewCell.h"

@interface JATileGridCollectionViewCell ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation JATileGridCollectionViewCell

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *gradientView = [UIView new];
        gradientView.frame = self.bounds;
        gradientView.layer.borderWidth = 1.0;
        gradientView.layer.borderColor = [UIColor blackColor].CGColor;
        gradientView.layer.cornerRadius = 4.0;
        gradientView.clipsToBounds = YES;
        
        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.frame = gradientView.frame;
        self.gradientLayer.startPoint = CGPointMake(0.0, 0.0);
        self.gradientLayer.endPoint = CGPointMake(1.0, 1.0);
        [gradientView.layer addSublayer:self.gradientLayer];
        
        [self addSubview:gradientView];
    }
    return self;
}

#pragma mark - Prepare View Components

- (void) applyGradientWithColors:(NSArray *) gradientColors
{
    self.gradientLayer.colors = gradientColors;
}

@end