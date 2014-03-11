//
//  HaloView.h
//  DynamicView
//
//  Created by Young Choi on 3/11/14.
//  Copyright (c) 2014 Young Choi. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 These values to anchor down the points so they can be either stay or move to positive/degative directions.
 Values can be 0, 1, or -1.
 0 = zero out (no_change), 1 = keep the sign bit, -1 = negate the sign bit.
 For example, setting x=0, y=0 will result no change to point (x,y).
 */
typedef struct Matrix
{
    CGFloat x;
    CGFloat y;
    CGFloat w;
    CGFloat h;
} Matrix;

typedef struct Eyeball
{
    CGPoint position;
    Matrix matrix;
} Eyeball;


@interface HaloView : UIView
@property (nonatomic, assign) CGFloat eyeballRadius;
@property (nonatomic, strong) UIColor *color;
- (Eyeball)eyeballForPoint:(CGPoint)touchPoint;

@end
