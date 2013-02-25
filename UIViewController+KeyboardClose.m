
//
//  UIViewController+KeyboardClose.m
//
//  Created by Dmitry Ponomarev
//  Copyright (c) 2012. All rights reserved.
//  License CC BY 3.0 http://creativecommons.org/licenses/by/3.0/deed.en_US
//
//  Thanks for: https://github.com/gavingmiller/evernote-show-hide-keyboard
//

#import "UIViewController+KeyboardClose.h"
#import <objc/runtime.h>

enum {
    mButtonWidth = 45,
    mButtonHeight = 25,
};

UIKIT_STATIC_INLINE UIViewAnimationOptions
_UIViewAnimationOptionsFromCurve(UIViewAnimationCurve curve)
{
    switch (curve) {
        case UIViewAnimationCurveEaseInOut:
            return UIViewAnimationOptionCurveEaseInOut;
        case UIViewAnimationCurveEaseIn:
            return UIViewAnimationOptionCurveEaseIn;
        case UIViewAnimationCurveEaseOut:
            return UIViewAnimationOptionCurveEaseOut;
        case UIViewAnimationCurveLinear:
            return UIViewAnimationOptionCurveLinear;
        default:
            return curve;
    }
}

@implementation UIViewController (KeyboardClose)

@dynamic keyboardInfo;

- (UIView *)keyboardAcceptView
{
    UIViewController *parent = self.parentViewController;
    if (parent && [parent isKindOfClass:[UINavigationController class]])
    {
        return parent.view;
    }
    return self.view;
}

- (void)registerKeyboardCloseButtonForIphone
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [self registerKeyboardCloseButton:NO];
    }
}

- (void)registerKeyboardCloseButton
{
    [self registerKeyboardCloseButton:NO];
}

- (void)registerKeyboardCloseButton:(BOOL)reset
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    if (reset)
    {
        [notificationCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [notificationCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }

    UIView *acceptableView = [self keyboardAcceptView];
    if (nil==acceptableView)
    {
        return;
    }
    
    UIButton *closeButton = (UIButton *)[acceptableView viewWithTag:tUIKeyboardCloseButton];
    if (nil!=closeButton)
    {
        [closeButton removeFromSuperview];
    }

    // Make button
    closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setFrame:CGRectMake(0, 0, mButtonWidth, mButtonHeight)];
    [closeButton setTag:tUIKeyboardCloseButton];

    // Set button position
    CGRect vFrame = self.view.frame;
    CGPoint position = [self keyboardCloseButtonPosition:closeButton keyboardFrame:CGRectMake(0, vFrame.size.height, vFrame.size.width, 300) show:NO];
    [closeButton setFrame:CGRectMake(position.x, position.y, mButtonWidth, mButtonHeight)];

    // Set button background
    UIImage *btnBackground = [[UIImage imageNamed:@"edit-button-bg.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
    [closeButton setBackgroundImage:btnBackground forState:UIControlStateNormal];
    [closeButton setBackgroundImage:btnBackground forState:UIControlStateHighlighted];

    // Set button keyboard image
    UIImageView *keyboard = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"edit-button-icon-keyboard.png"]];
    keyboard.frame = CGRectMake(5, 5, 22, 14);
    keyboard.tag = tUIKeyboardCloseButtonKeyBoardImage;
    [closeButton addSubview:keyboard];

    // Set button arrow image
    UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"edit-button-icon-up.png"]];
    arrow.frame = CGRectMake(31, 5, 10, 14);
    [closeButton addSubview:arrow];
    closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
    
    [acceptableView addSubview:closeButton];
    [acceptableView bringSubviewToFront:closeButton];

    // Set button close event
    [closeButton addTarget:self action:@selector(clickKeyboardCloseButton:) forControlEvents:UIControlEventTouchUpInside];

    [closeButton setEnabled:NO];
    [closeButton setAlpha:0.0f];

    // Register keyboard event control
    [notificationCenter addObserver:self selector:@selector(keyboardCloseButtonWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardCloseButtonWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterKeyboardCloseButton
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    UIView *acceptableView = [self keyboardAcceptView];
    if (acceptableView)
    {
        UIButton *closeButton = (UIButton *)[acceptableView viewWithTag:tUIKeyboardCloseButton];

        if (closeButton)
        {
            [closeButton removeTarget:self action:@selector(clickKeyboardCloseButton:) forControlEvents:UIControlEventTouchUpInside];
            [closeButton removeFromSuperview];
        }
    }
}

/**
 * Use only when to destroy controller
 * @return void
 */
- (void)unregisterKeyboardCloseButtonFast
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    UIView *acceptableView = [self keyboardAcceptView];
    UIButton *closeButton = (UIButton *)[acceptableView viewWithTag:tUIKeyboardCloseButton];

    if (closeButton)
    {
        [closeButton removeTarget:self action:@selector(clickKeyboardCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        [closeButton removeFromSuperview];
    }
}

#pragma mark button animations

- (void)keyboardCloseButtonShow:(UIButton *)closeButton
                 animationCurve:(UIViewAnimationCurve)animationCurve
              animationDuration:(NSTimeInterval)animationDuration
               keyboardFrameEnd:(CGRect)frameEnd
{
    UIImageView *keyboard = (UIImageView *)[closeButton viewWithTag:tUIKeyboardCloseButtonKeyBoardImage];
    UIView *acceptView = [self keyboardAcceptView];
    [acceptView bringSubviewToFront:closeButton];

    [UIView animateWithDuration:animationDuration delay:0.0
            options:(_UIViewAnimationOptionsFromCurve(animationCurve) | UIViewAnimationOptionBeginFromCurrentState)
         animations:^
        {
            CGRect frame = [closeButton frame];
            frame.origin = [self keyboardCloseButtonPosition:closeButton keyboardFrame:frameEnd show:YES];
            
            if ([acceptView isKindOfClass:[UIScrollView class]])
            {
                frame.origin.y += ((UIScrollView *)acceptView).contentOffset.y;
            }
            if (frame.origin.y>0)
            {
                [closeButton setFrame:frame];
                [closeButton setAlpha:1.0f];
                
                keyboard.transform = CGAffineTransformMakeRotation(M_PI);
                closeButton.transform = CGAffineTransformMakeRotation(M_PI);
            }
        }
         completion:^(BOOL finished)
        {
            [closeButton setEnabled:YES];
        }
    ];
}

- (void)keyboardCloseButtonHide:(UIButton *)closeButton
                 animationCurve:(UIViewAnimationCurve)animationCurve
              animationDuration:(NSTimeInterval)animationDuration
               keyboardFrameEnd:(CGRect)frameEnd
{
    UIImageView *keyboard = (UIImageView *)[closeButton viewWithTag:tUIKeyboardCloseButtonKeyBoardImage];

    [UIView animateWithDuration:animationDuration delay:0.0
            options:(_UIViewAnimationOptionsFromCurve(animationCurve) | UIViewAnimationOptionBeginFromCurrentState)
         animations:^
        {
            CGRect frame = [closeButton frame];
            frame.origin = [self keyboardCloseButtonPosition:closeButton keyboardFrame:frameEnd show:NO];
            [closeButton setFrame:frame];
            [closeButton setAlpha:0.0f];
            
            keyboard.transform = CGAffineTransformMakeRotation(0);
            closeButton.transform = CGAffineTransformMakeRotation(0);
        }
         completion:^(BOOL finished)
        {
            [closeButton setEnabled:NO];
        }
    ];
}

- (CGPoint)keyboardCloseButtonPosition:(UIButton *)closeButton keyboardFrame:(CGRect)keyboardFrame show:(BOOL)show;
{
    CGSize btnSize = [closeButton bounds].size;
    const CGFloat viewOffset = MAX(keyboardFrame.origin.y, keyboardFrame.origin.x);
    const CGFloat kWidth = MAX(keyboardFrame.size.width, keyboardFrame.size.height);
    if (show)
    {
        return CGPointMake(
            kWidth-btnSize.width-7,
            viewOffset-btnSize.height-self.keyboardAcceptView.frame.origin.y-7);
    }
    return CGPointMake(kWidth-btnSize.width-7, viewOffset+10);
}

#pragma mark keyboard notifications

- (void)keyboardCloseButtonWillShow:(NSNotification *)notification
{
    if (!self || ![self isViewLoaded] || !self.view.window)
        return;

    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect frameEnd;

    NSDictionary *userInfo = [notification userInfo];
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&frameEnd];
    
    if (0==frameEnd.origin.x && 0==frameEnd.origin.y)
    {
        UIWindow *w = self.view.window;
        if (w)
        {
            frameEnd.origin.y = w.frame.size.height-frameEnd.size.height;
            frameEnd.origin.x = w.frame.size.width-frameEnd.size.width;
        }
    }

    UIView *acceptableView = [self keyboardAcceptView];
    UIButton *closeButton = (UIButton *)[acceptableView viewWithTag:tUIKeyboardCloseButton];
    [acceptableView bringSubviewToFront:closeButton];

    self.keyboardInfo = userInfo;

    [self keyboardCloseButtonShow:closeButton
                   animationCurve:animationCurve
                animationDuration:animationDuration
                 keyboardFrameEnd:frameEnd];
}

- (void)keyboardCloseButtonWillHide:(NSNotification *)notification
{
    if (!self || ![self isViewLoaded])
        return;

    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect frameEnd;

    NSDictionary *userInfo = [notification userInfo];
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&frameEnd];

    UIView *acceptView = [self keyboardAcceptView];
    UIButton *closeButton = (UIButton *)[acceptView viewWithTag:tUIKeyboardCloseButton];
    [acceptView bringSubviewToFront:closeButton];

    self.keyboardInfo = nil;

    [self keyboardCloseButtonHide:closeButton
                   animationCurve:animationCurve
                animationDuration:animationDuration
                 keyboardFrameEnd:frameEnd];
}

#pragma mark scroll event

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.keyboardInfo && self.view == [self keyboardAcceptView])
    {
        CGRect frameEnd;
        [[self.keyboardInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&frameEnd];

        if (0==frameEnd.origin.x && 0==frameEnd.origin.y)
        {
            UIWindow *w = self.view.window;
            frameEnd.origin.y = w.frame.size.height-frameEnd.size.height;
            frameEnd.origin.x = w.frame.size.width-frameEnd.size.width;
        }

        UIView *acceptView = [self keyboardAcceptView];
        UIButton *closeButton = (UIButton *)[acceptView viewWithTag:tUIKeyboardCloseButton];
        if (closeButton)
        {
            CGRect frame = [closeButton frame];
            frame.origin = [self keyboardCloseButtonPosition:closeButton keyboardFrame:frameEnd show:YES];
            frame.origin.y += scrollView.contentOffset.y;
            [closeButton setFrame:frame];
        }
    }
}

#pragma mark button events

- (void)clickKeyboardCloseButton:(id)sender
{
    [self.view endEditing:YES];
}

#pragma mark get/set property

static const char *keyboardInfoKey = "keyboardInfo";

- (void)setKeyboardInfo:(NSDictionary *)keyboardInfo
{
	objc_setAssociatedObject(self, keyboardInfoKey, keyboardInfo, OBJC_ASSOCIATION_RETAIN);
}
 
- (NSDictionary *)keyboardInfo
{
	return objc_getAssociatedObject(self, keyboardInfoKey);
}

@end
