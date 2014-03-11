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
    }
    
    return _dynamicViews;
}

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor grayColor];
    
    // Enable a tap gesture.
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureDetacted:)];
    gestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:gestureRecognizer];
    
    // (1) Add an dynamicView with a simple background content view.
    DynamicView *dynamicViewWithNoContents = [[DynamicView alloc] initWithFrame:CGRectMake(300, 300, 400, 200)];
    dynamicViewWithNoContents.delegate = self;
    UIView *contentView = [[UIView alloc] initWithFrame:dynamicViewWithNoContents.frame];
    [contentView setBackgroundColor:[UIColor clearColor]];
    dynamicViewWithNoContents.contentView = contentView;
    dynamicViewWithNoContents.grounded = NO;
    dynamicViewWithNoContents.proportional = NO;
    [self.dynamicViews addObject:dynamicViewWithNoContents];
    
    // (2) Add another one with a UIImageView as the content.
    DynamicView *dynamicViewWithImage = [[DynamicView alloc] initWithFrame:CGRectMake(50, 200, 100, 200)];
    dynamicViewWithImage.delegate = self;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
    dynamicViewWithImage.contentView = imageView;
    dynamicViewWithImage.contentView.backgroundColor = [UIColor yellowColor];
    dynamicViewWithImage.grounded = YES;
    dynamicViewWithImage.proportional = YES;
    [self.dynamicViews addObject:dynamicViewWithImage];
    
    self.currentDynamicView = dynamicViewWithNoContents;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    for(UIView *v in self.dynamicViews)
    {
        [self.view addSubview:v];
    }
    
    // Shuffle them
    [self.view bringSubviewToFront:self.currentDynamicView];
    [self.currentDynamicView showHaloView];
}

#pragma mark - DynamicViewDelegate
- (void)dynamicViewDidBeginTouches:(DynamicView *)dynamicView
{
    [self.currentDynamicView hideHaloView];
    self.currentDynamicView = dynamicView;
}

- (void)dynamicViewDidEndTouches:(DynamicView *)dynamicView
{
    self.previousDynamicView = dynamicView;
}

#pragma mark - UIGestureRecognizerDelegate
- (void)tapGestureDetacted:(UIGestureRecognizer *)gestureRecognizer
{
    // De-select it (hide the haloView).
    [self.previousDynamicView hideHaloView];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // Ignore taps within the current dynamicView.
    UIView *v = self.currentDynamicView;
    if ([v hitTest:[touch locationInView:v] withEvent:nil])
    {
        // User tapped inside of the current dynamicView.
        return NO;
    }
    
    // User tapped anywhere outside of the current dynamicView.
    return YES;
}

@end
