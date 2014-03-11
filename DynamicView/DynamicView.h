//
//  DynamicView.h
//  DynamicView
//
//  Created by Young Choi on 3/11/14.
//  Copyright (c) 2014 Young Choi. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <Foundation/Foundation.h>

@protocol DynamicViewDelegate;


@interface DynamicView : UIView

@property (nonatomic, assign) id <DynamicViewDelegate> delegate;
@property (nonatomic, strong) UIView *contentView;


// Defaults to NO. Allow users from dragging the view outside the parent view's bounds.
@property (nonatomic) BOOL grounded; // same as clipsToBounds?
@property (nonatomic) BOOL proportional;

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
