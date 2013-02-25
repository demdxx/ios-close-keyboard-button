//
//  UIViewController+KeyboardClose.h
//
//  Created by Dmitry Ponomarev
//  Copyright (c) 2012. All rights reserved.
//  License CC BY 3.0 http://creativecommons.org/licenses/by/3.0/deed.en_US
//
//  Thanks for: https://github.com/gavingmiller/evernote-show-hide-keyboard
//

#import <Foundation/Foundation.h>

enum {
    tUIKeyboardCloseButton = 94328,
    tUIKeyboardCloseButtonKeyBoardImage,
};

@interface UIViewController (KeyboardClose)

@property (nonatomic, retain) NSDictionary* keyboardInfo;

- (UIView *)keyboardAcceptView;

- (void)registerKeyboardCloseButtonForIphone;
- (void)registerKeyboardCloseButton;
- (void)registerKeyboardCloseButton:(BOOL)reset;
- (void)unregisterKeyboardCloseButton;

/**
 * Use only when to destroy controller
 */
- (void)unregisterKeyboardCloseButtonFast;

- (void)keyboardCloseButtonShow:(UIButton *)closeButton
                 animationCurve:(UIViewAnimationCurve)animationCurve
              animationDuration:(NSTimeInterval)animationDuration
               keyboardFrameEnd:(CGRect)frameEnd;
- (void)keyboardCloseButtonHide:(UIButton *)closeButton
                 animationCurve:(UIViewAnimationCurve)animationCurve
              animationDuration:(NSTimeInterval)animationDuration
               keyboardFrameEnd:(CGRect)frameEnd;

- (CGPoint)keyboardCloseButtonPosition:(UIButton *)closeButton keyboardFrame:(CGRect)keyboardFrame show:(BOOL)show;

- (void)keyboardCloseButtonWillShow:(NSNotification *)notification;
- (void)keyboardCloseButtonWillHide:(NSNotification *)notification;

- (void)clickKeyboardCloseButton:(id)sender;

@end
