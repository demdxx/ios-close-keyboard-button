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

- (void)registerKeyboardCloseButton
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIButton *closeButton = (UIButton *)[window viewWithTag:tUIKeyboardCloseButton];
    
    if (nil==closeButton)
    {
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
        
        [window addSubview:closeButton];
        [window bringSubviewToFront:closeButton];
        
        // Set button close event
        [closeButton addTarget:self action:@selector(clickKeyboardCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [closeButton setEnabled:NO];
    [closeButton setAlpha:0.0f];

    // Register keyboard event control
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(keyboardCloseButtonWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardCloseButtonWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterKeyboardCloseButton
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

/**
 * Use only when to destroy controller
 * @return void
 */
- (void)unregisterKeyboardCloseButtonFast
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark button animations

- (void)keyboardCloseButtonShow:(UIButton *)closeButton
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
            frame.origin = [self keyboardCloseButtonPosition:closeButton keyboardFrame:frameEnd show:YES];
            [closeButton setFrame:frame];
            [closeButton setAlpha:1.0f];
            
            keyboard.transform = CGAffineTransformMakeRotation(M_PI);
            closeButton.transform = CGAffineTransformMakeRotation(M_PI);
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
    CGRect btnFrame = [closeButton frame];
    if (show)
    {
        CGFloat viewHeight = keyboardFrame.origin.y; //[self.view convertRect:keyboardFrame fromView:nil].origin.y;

        return CGPointMake(keyboardFrame.size.width-btnFrame.size.width-7, viewHeight-btnFrame.size.height-8);
    }
    return CGPointMake(keyboardFrame.size.width-btnFrame.size.width-7, keyboardFrame.origin.y+10);
}

#pragma mark keyboard notifications

- (void)keyboardCloseButtonWillShow:(NSNotification *)notification
{
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect frameEnd;

    NSDictionary *userInfo = [notification userInfo];
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&frameEnd];

    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIButton *closeButton = (UIButton *)[window viewWithTag:tUIKeyboardCloseButton];
    [window bringSubviewToFront:closeButton];

    [self keyboardCloseButtonShow:closeButton
                   animationCurve:animationCurve
                animationDuration:animationDuration
                 keyboardFrameEnd:frameEnd];
}

- (void)keyboardCloseButtonWillHide:(NSNotification *)notification
{
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect frameEnd;

    NSDictionary *userInfo = [notification userInfo];
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&frameEnd];

    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIButton *closeButton = (UIButton *)[window viewWithTag:tUIKeyboardCloseButton];
    [window bringSubviewToFront:closeButton];

    [self keyboardCloseButtonHide:closeButton
                   animationCurve:animationCurve
                animationDuration:animationDuration
                 keyboardFrameEnd:frameEnd];
}

#pragma mark button events

- (void)clickKeyboardCloseButton:(id)sender
{
    [self.view endEditing:YES];
}

@end
