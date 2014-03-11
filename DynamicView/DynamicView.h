//
//  DynamicView.h
//  DynamicView
//
//  Created by Young Choi on 3/11/14.
//  Copyright (c) 2014 Young Choi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DynamicViewDelegate;

@interface DynamicView : UIView

@property (nonatomic, assign) id <DynamicViewDelegate> delegate;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic) BOOL grounded;        // Defaults to NO.
@property (nonatomic) BOOL proportional;    // Defaults to NO.

- (void)hideHaloView;
- (void)showHaloView;

@end


// Protocol
@protocol DynamicViewDelegate <NSObject>
@optional
// Called when a dynamicView receives touchesBegan:
- (void)dynamicViewDidBeginTouches:(DynamicView *)dynamicView;

// Called when a dynamicView receives touchesEnded: or touchesCancelled:
- (void)dynamicViewDidEndTouches:(DynamicView *)dynamicView;
@end
