//
//  ViewController.m
//  DynamicView
//
//  Created by Young Choi on 3/11/14.
//  Copyright (c) 2014 Young Choi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) NSMutableArray *dynamicViews;
@property (nonatomic, strong) DynamicView *currentDynamicView;
@property (nonatomic, strong) DynamicView *previousDynamicView;
@end

@implementation ViewController

- (NSMutableArray*)dynamicViews
{
    if(!_dynamicViews)
    {
        _dynamicViews = [[NSMutableArray alloc] init];
        
        // TEMP: Store two dynamic views into a container.
        {
        // Add a dynamicView with a UIImageView content.
        DynamicView *dynamicViewWithImage = [[DynamicView alloc] initWithFrame:CGRectMake(50, 200, 100, 200)];
        dynamicViewWithImage.delegate = self;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
        dynamicViewWithImage.contentView = imageView;
        dynamicViewWithImage.contentView.backgroundColor = [UIColor yellowColor];
        dynamicViewWithImage.grounded = YES;
        dynamicViewWithImage.proportional = YES;
        [_dynamicViews addObject:dynamicViewWithImage];
        
        // Add another dynamicView with no content.
        DynamicView *dynamicViewWithNoContents = [[DynamicView alloc] initWithFrame:CGRectMake(300, 300, 400, 200)];
        dynamicViewWithNoContents.delegate = self;
        UIView *contentView = [[UIView alloc] initWithFrame:dynamicViewWithNoContents.frame];
        [contentView setBackgroundColor:[UIColor clearColor]];
        dynamicViewWithNoContents.contentView = contentView;
        dynamicViewWithNoContents.grounded = NO;
        dynamicViewWithNoContents.proportional = NO;
        [_dynamicViews addObject:dynamicViewWithNoContents];
        }
    }
    
    return _dynamicViews;
}

- (void)viewDidLoad
{
    //self.view.backgroundColor = [UIColor grayColor];
    
    // Load all dynamic views.
    for(UIView *v in self.dynamicViews)
    {
        [self.view addSubview:v];
    }
    
    // Pick one and shuffle it up to top and glow.
    self.currentDynamicView = [self.dynamicViews lastObject]; // initially the last one in the list.
    [self.view bringSubviewToFront:self.currentDynamicView];
    [self.currentDynamicView showHaloView];
    
    // Enable a tap gesture.
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureDetacted:)];
    gestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:gestureRecognizer];
}

#pragma mark - DynamicViewDelegate
- (void)dynamicViewDidBeginTouches:(DynamicView *)dynamicView
{
    // Replace the currentDynamicView with user touched one.
    [self.currentDynamicView hideHaloView];
    self.currentDynamicView = dynamicView;
    
    // Bring it to the top.
    [self.view bringSubviewToFront:self.currentDynamicView];
}

- (void)dynamicViewDidEndTouches:(DynamicView *)dynamicView
{
    self.previousDynamicView = dynamicView;
}

#pragma mark - UIGestureRecognizerDelegate
- (void)tapGestureDetacted:(UIGestureRecognizer *)gestureRecognizer
{
    // De-select it.
    [self.previousDynamicView hideHaloView];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // Ignore taps within the current dynamicView, and allow anywhere else.
    UIView *v = self.currentDynamicView;
    return [v hitTest:[touch locationInView:v] withEvent:nil] ? NO : YES;
}

@end
