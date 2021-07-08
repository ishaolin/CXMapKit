//
//  CXActionBubbleView.h
//  Pods
//
//  Created by wshaolin on 2017/5/21.
//
//

#import <UIKit/UIKit.h>

@class CXActionBubbleViewBorderShadow;

typedef NS_ENUM(NSInteger, CXActionBubbleViewArrowDirection){
    CXActionBubbleViewArrowDirectionTop     = 1,
    CXActionBubbleViewArrowDirectionLeft    = 2,
    CXActionBubbleViewArrowDirectionBottom  = 3,
    CXActionBubbleViewArrowDirectionRight   = 4
};

@interface CXActionBubbleView : UIControl

@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, assign, readonly) CGSize visibleSize; // 不包含箭头部分

@property (nonatomic, assign) CGSize contentSize; // 子类根据具体内容设置，必须设置
@property (nonatomic, assign) CGFloat cornerRadius;

@property (nonatomic, assign, getter = isAdjustsColorWhenHighlighted) BOOL adjustsColorWhenHighlighted;

- (instancetype)initWithArrowDirection:(CXActionBubbleViewArrowDirection)arrowDirection;

- (instancetype)initWithArrowDirection:(CXActionBubbleViewArrowDirection)arrowDirection
                             arrowSize:(CGFloat)arrowSize;

- (instancetype)initWithArrowDirection:(CXActionBubbleViewArrowDirection)arrowDirection
                             arrowSize:(CGFloat)arrowSize
                          borderShadow:(CXActionBubbleViewBorderShadow *)borderShadow;

- (void)setBubbleColor:(UIColor *)bubbleColor forState:(UIControlState)state;

@end

@interface CXActionBubbleViewBorderShadow : NSObject

@property (nonatomic, strong) UIColor *shadowColor;
@property (nonatomic, assign) CGSize shadowOffset;
@property (nonatomic, assign) CGFloat shadowRadius;
@property (nonatomic, assign) CGFloat shadowOpacity;

+ (instancetype)defaultBorderShadow;

@end
