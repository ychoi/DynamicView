//
//  DynamicView.m
//  DynamicView
//
//  Created by Young Choi on 3/11/14.
//  Copyright (c) 2014 Young Choi. All rights reserved.
//

#import "DynamicView.h"
#import "HaloView.h"

#define kEyeballRadius 5

@interface DynamicView ()
@property (nonatomic) CGPoint touchStart;
@property (nonatomic, strong) HaloView *haloView;

// Used to determine which components of the bounds we'll be modifying, based upon where the user's touch started.
@property (nonatomic, assign) Eyeball pokedEye;
@end

@implementation DynamicView

#pragma mark - Instance Life Cycle
- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self defaultAttributes];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self defaultAttributes];
    }
    return self;
}

- (void)defaultAttributes
{
    self.grounded = NO;
    self.haloView.hidden = YES;
    self.proportional = NO;
}

#pragma mark - Private Getter/Setter
- (HaloView*)haloView
{
    if(!_haloView)
    {
        _haloView = [[HaloView alloc] initWithFrame:CGRectInset(self.bounds, kEyeballRadius, kEyeballRadius)];
        _haloView.eyeballRadius = kEyeballRadius;
        [self addSubview:_haloView];
    }
    
    return _haloView;
}

#pragma mark - Public APIs
- (void)setContentView:(UIView *)iContentView
{
    [_contentView removeFromSuperview];
    _contentView = iContentView;
    _contentView.frame = CGRectInset(self.haloView.frame, kEyeballRadius, kEyeballRadius);
    [self addSubview:_contentView];
    
    // Shuffle them. Ensure the haloView is always on top.
    [self bringSubviewToFront:self.haloView];
}

- (void)setFrame:(CGRect)iFrame
{
    [super setFrame:iFrame];
    
    // Expand the frame for HaloView by eyeball eyeballRadius to include the other half side of the eyeballs.
    self.haloView.frame = CGRectInset(self.bounds, self.haloView.eyeballRadius, self.haloView.eyeballRadius);
    
    self.contentView.frame = CGRectInset(self.haloView.frame, kEyeballRadius, kEyeballRadius);
    
    [self.haloView setNeedsDisplay];
}

- (void)showHaloView
{
    self.haloView.hidden = NO;
}

- (void)hideHaloView
{
    self.haloView.hidden =YES;
}

- (BOOL)isResizing
{
    Matrix matrix = self.pokedEye.matrix;
    
    BOOL isCenterRect = (!matrix.x && !matrix.y && !matrix.w && !matrix.h);
    return isCenterRect ? NO : YES;
}

#pragma mark - Touch Event Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(dynamicViewDidBeginTouches:)])
    {
        [self.delegate dynamicViewDidBeginTouches:self];
    }
    
    // Show haloView.
    [self showHaloView];
    
    UITouch *touch = [touches anyObject];
    
    // (1) Get the eyeball for the point user poked at.
    self.pokedEye = [self.haloView eyeballForPoint:[touch locationInView:self.haloView]];
    
    // (2) Save the staring point.
    self.touchStart = [self isResizing] ? [touch locationInView:self.superview] : [touch locationInView:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(dynamicViewDidEndTouches:)])
    {
        [self.delegate dynamicViewDidEndTouches:self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(dynamicViewDidEndTouches:)])
    {
        [self.delegate dynamicViewDidEndTouches:self];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Resizing is based on the superview's coordinate space.
    // Moving is based on the view's coordinate space.
    if ([self isResizing])
    {
        [self resizeTo:[[touches anyObject] locationInView:self.superview]];
    }
    else
    {
        [self translateTo:[[touches anyObject] locationInView:self]];
    }
}

- (void)resizeTo:(CGPoint)touchEnd
{
    Matrix matrix = self.pokedEye.matrix;
    
    // Get the delta values.
    CGFloat dw = matrix.w * (self.touchStart.x - touchEnd.x);
    CGFloat dh = matrix.h * (self.touchStart.y - touchEnd.y);
    CGFloat dx = matrix.x * dw;
    CGFloat dy = matrix.y * dh;
    
    // Get a new frame values from the delta values.
    CGFloat xx = self.frame.origin.x + dx;
    CGFloat yy = self.frame.origin.y + dy;
    CGFloat ww = self.frame.size.width + dw;
    CGFloat hh = self.frame.size.height + dh;
    
    // Adjust the newly formed frame as needed.
    if(self.proportional)
    {
        // Adjust the size to keep the same ratio as original.
        
        CGFloat w = self.frame.size.width;
        CGFloat h = self.frame.size.height;
        
        CGFloat originalRatio = w/h;
        CGFloat modifiedRatio = ww/hh;
        
        BOOL expanding = (ww-w > 0 || hh-h > 0) ? YES : NO;
        
        if(originalRatio > modifiedRatio)
        {
            if(expanding)
            {
                ww = w + ((h+dh)*w/h)-w;
            }
            else
            {
                hh = h + ((w+dw)*h/w)-h;
            }
        }
        else if(originalRatio < modifiedRatio)
        {
            if(expanding)
            {
                hh = h + ((w+dw)*h/w)-h;
            }
            else
            {
                ww = w + ((h+dh)*w/h)-w;
            }
        }
        
    }
    else
    {
        // Ratio is irrelavant.
    }
    
    // Limit the smallest size it can be. (3 eyeballs width.)
    CGFloat minimumSideLength = self.haloView.eyeballRadius*2*3;
    if(self.proportional)
    {
        CGFloat originalRatio = self.frame.size.width/self.frame.size.height;
        
        if(ww < minimumSideLength || hh < minimumSideLength)
        {
            if (ww == MIN(ww, hh))
            {
                ww = minimumSideLength;
                hh = minimumSideLength + (ww) * originalRatio;
            }
            else
            {
                hh = minimumSideLength;
                ww = minimumSideLength + (hh) * originalRatio;
            }
        }
    }
    else
    {
        ww = (ww < minimumSideLength) ? minimumSideLength : ww;
        hh = (hh < minimumSideLength) ? minimumSideLength : hh;
    }
    
    self.frame = CGRectMake(xx, yy, ww, hh);
    self.touchStart = touchEnd;
}

- (void)translateTo:(CGPoint)touchPoint
{
    // Get the deltas.
    CGFloat dx = touchPoint.x - self.touchStart.x;
    CGFloat dy = touchPoint.y - self.touchStart.y;
    
    CGPoint aCenter = CGPointMake(self.center.x + dx, self.center.y + dy);
    
    if (self.grounded)
    {
        // Ensure the translation stays within the superview's bounds.
        CGFloat midX = CGRectGetMidX(self.bounds);
        if (aCenter.x > self.superview.bounds.size.width - midX)
        {
            aCenter.x = self.superview.bounds.size.width - midX;
        }
        if (aCenter.x < midX)
        {
            aCenter.x = midX;
        }
        CGFloat midY = CGRectGetMidY(self.bounds);
        if (aCenter.y > self.superview.bounds.size.height - midY)
        {
            aCenter.y = self.superview.bounds.size.height - midY;
        }
        if (aCenter.y < midY)
        {
            aCenter.y = midY;
        }
    }
    self.center = aCenter;
}

#pragma mark - Utility Methods

@end
