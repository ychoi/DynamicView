//
//  HaloView.m
//  DynamicView
//
//  Created by Young Choi on 3/11/14.
//  Copyright (c) 2014 Young Choi. All rights reserved.
//

#import "HaloView.h"

@interface HaloView()
@property (nonatomic, strong) NSArray *eyeballs;
@end

@implementation HaloView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        self.eyeballRadius = 0.0;
        self.color = [UIColor blueColor];
    }
    return self;
}

- (NSArray*)eyeballs
{
    if(!_eyeballs)
    {
        NSMutableArray *eyeballs = [[NSMutableArray alloc] initWithCapacity:9];
        
        CGFloat w = self.bounds.size.width;
        CGFloat h = self.bounds.size.height;
        CGFloat d = self.eyeballRadius*2;
        Eyeball topLeft =       {CGPointMake(0, 0),    {-1, -1, 1, 1}};
        Eyeball topRight =      {CGPointMake(w-d, 0),    {0, -1, -1, 1}};
        Eyeball bottomLeft =    {CGPointMake(0, h-d),    {-1, 0, 1, -1}};
        Eyeball bottomRight =   {CGPointMake(w-d, h-d),    {0, 0, -1, -1}};
        Eyeball topSide =       {CGPointMake((w-d)/2, 0),  {0, -1, 0, 1}};
        Eyeball bottomSide =    {CGPointMake((w-d)/2, h-d),  {0, 0, 0, -1}};
        Eyeball leftSide =      {CGPointMake(0, (h-d)/2),  {-1, 0, 1, 0}};
        Eyeball rightSide =     {CGPointMake(w-d, (h-d)/2),  {0, 0, -1, 0}};
        Eyeball centerPoint =   {CGPointMake((w-d)/2, (h-d)/2),{0, 0, 0, 0}};
        
        [eyeballs addObject:[NSValue valueWithBytes: &topLeft objCType: @encode(struct Eyeball)]];
        [eyeballs addObject:[NSValue valueWithBytes: &topRight objCType: @encode(struct Eyeball)]];
        [eyeballs addObject:[NSValue valueWithBytes: &bottomLeft objCType: @encode(struct Eyeball)]];
        [eyeballs addObject:[NSValue valueWithBytes: &bottomRight objCType: @encode(struct Eyeball)]];
        [eyeballs addObject:[NSValue valueWithBytes: &topSide objCType: @encode(struct Eyeball)]];
        [eyeballs addObject:[NSValue valueWithBytes: &bottomSide objCType: @encode(struct Eyeball)]];
        [eyeballs addObject:[NSValue valueWithBytes: &leftSide objCType: @encode(struct Eyeball)]];
        [eyeballs addObject:[NSValue valueWithBytes: &rightSide objCType: @encode(struct Eyeball)]];
        [eyeballs addObject:[NSValue valueWithBytes: &centerPoint objCType: @encode(struct Eyeball)]];
        
        _eyeballs = [[NSArray alloc] initWithArray:eyeballs];
    }
    return _eyeballs;
}

- (Eyeball)eyeballForPoint:(CGPoint)touchPoint
{
    Eyeball eyeball;
    [[self.eyeballs lastObject] getValue:&eyeball]; // default to be the center point
    
    
    CGFloat kFingerWidth = 22;
    
    for (NSInteger i = 0; i < self.eyeballs.count; i++)
    {
        Eyeball aEyeball;
        [self.eyeballs[i] getValue:&aEyeball];
        
        CGFloat distance = [self distanceFrom:touchPoint to:aEyeball.position];
        
        /*
         Mk a tmp view layer with radius 40/2. and do hitTest on it with touchPoint to determine the right eyeball.
         */
        if (distance <= kFingerWidth)
        {
            eyeball = aEyeball;
            break;
        }
    }
    
    return eyeball;
}

#pragma mark - Util Methods
- (CGFloat)distanceFrom:(CGPoint)pt1  to:(CGPoint)pt2
{
    // PythagorasTheorem
    CGFloat dx = pt2.x - pt1.x;
    CGFloat dy = pt2.y - pt1.y;
    return sqrt(dx*dx + dy*dy);
};

#pragma mark - Draw Methods
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    // (1) Draw the outter edge boundary rectangle.
    CGContextSetLineWidth(ctx, 1.0);
    CGContextSetStrokeColorWithColor(ctx, self.color.CGColor);
    CGContextAddRect(ctx, CGRectInset(self.bounds, self.eyeballRadius, self.eyeballRadius));
    CGContextStrokePath(ctx);
    
    // (2) Create the gradient to paint the eyeballs.
    CGFloat colors [] = {
        0.3, 0.7, 1.0, 1.0,
        0.0, 0.0, 1.0, 1.0
    };
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace);
    
    // (3) Set up the stroke for drawing the border of each of the eyeballs.
    CGContextSetLineWidth(ctx, 1);
    //CGContextSetShadow(ctx, CGSizeMake(0.5, 0.5), 1);
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    
    // (4) Fill each eyeball using the gradient, then stroke the border.
    for (NSInteger i = 0; i < self.eyeballs.count-1; i++)
    {
        Eyeball aEyeball;
        [self.eyeballs[i] getValue:&aEyeball];
        
        CGPoint eyeballAt = CGPointMake(aEyeball.position.x, aEyeball.position.y);
        CGSize eyeballSize = CGSizeMake(self.eyeballRadius*2, self.eyeballRadius*2);
        CGRect frame = CGRectZero;
        frame.origin = eyeballAt;
        frame.size = eyeballSize;
        
        // Pupil. Apply gradient in blue-ish from top to bottom at the center of the eyeball.
        CGContextSaveGState(ctx);
        CGContextAddEllipseInRect(ctx, frame);
        CGContextClip(ctx);
        CGPoint startPoint = CGPointMake(CGRectGetMidX(frame), CGRectGetMinY(frame));
        CGPoint endPoint = CGPointMake(CGRectGetMidX(frame), CGRectGetMaxY(frame));
        CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
        CGContextRestoreGState(ctx);
        
        // Iris, stroke with white 1/4 of pupil radius.
        CGContextStrokeEllipseInRect(ctx, CGRectInset(frame, self.eyeballRadius/4, self.eyeballRadius/4));
    }
    CGGradientRelease(gradient);
    
    CGContextRestoreGState(ctx);
    
    // Force it to refresh.
    self.eyeballs = nil;
}

@end
