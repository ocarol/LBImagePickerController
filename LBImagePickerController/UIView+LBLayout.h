//
//  UIView+LBLayout.h
//
//  Created by 谭真 on 15/2/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    LBOscillatoryAnimationToBigger,
    LBOscillatoryAnimationToSmaller,
} LBOscillatoryAnimationType;

@interface UIView (LBLayout)

@property (nonatomic) CGFloat lb_left;        ///< Shortcut for frame.origin.x.
@property (nonatomic) CGFloat lb_top;         ///< Shortcut for frame.origin.y
@property (nonatomic) CGFloat lb_right;       ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat lb_bottom;      ///< Shortcut for frame.origin.y + frame.size.height
@property (nonatomic) CGFloat lb_width;       ///< Shortcut for frame.size.width.
@property (nonatomic) CGFloat lb_height;      ///< Shortcut for frame.size.height.
@property (nonatomic) CGFloat lb_centerX;     ///< Shortcut for center.x
@property (nonatomic) CGFloat lb_centerY;     ///< Shortcut for center.y
@property (nonatomic) CGPoint lb_origin;      ///< Shortcut for frame.origin.
@property (nonatomic) CGSize  lb_size;        ///< Shortcut for frame.size.

+ (void)showOscillatoryAnimationWithLayer:(CALayer *)layer type:(LBOscillatoryAnimationType)type;

@end
