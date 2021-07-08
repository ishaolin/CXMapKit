//
//  CXActionBubbleView.m
//  Pods
//
//  Created by wshaolin on 2017/5/21.
//
//

#import "CXActionBubbleView.h"

@interface CXActionBubbleView(){
    CXActionBubbleViewBorderShadow *_borderShadow;
    CXActionBubbleViewArrowDirection _arrowDirection;
    CGFloat _arrowSize;
    UIEdgeInsets _contentInsets;
    NSMutableDictionary<NSNumber *, UIColor *> *_stateColors;
}

@end

@implementation CXActionBubbleView

- (instancetype)initWithArrowDirection:(CXActionBubbleViewArrowDirection)arrowDirection{
    return [self initWithArrowDirection:arrowDirection arrowSize:8.0];
}

- (instancetype)initWithArrowDirection:(CXActionBubbleViewArrowDirection)arrowDirection
                             arrowSize:(CGFloat)arrowSize{
    return [self initWithArrowDirection:arrowDirection arrowSize:arrowSize borderShadow:[CXActionBubbleViewBorderShadow defaultBorderShadow]];
}

- (instancetype)initWithArrowDirection:(CXActionBubbleViewArrowDirection)arrowDirection
                             arrowSize:(CGFloat)arrowSize
                          borderShadow:(CXActionBubbleViewBorderShadow *)borderShadow{
    if(self = [super initWithFrame:CGRectZero]){
        [super setOpaque:NO];
        _borderShadow = borderShadow;
        _arrowSize = arrowSize;
        _arrowDirection = arrowDirection;
        _adjustsColorWhenHighlighted = NO;
        
        _contentView = [[UIView alloc] init];
        _contentView.opaque = NO;
        _contentView.userInteractionEnabled = NO;
        [self addSubview:_contentView];
        
        _stateColors = [NSMutableDictionary dictionary];
        [self updateContentInsets];
        
        if(_borderShadow != nil){
            self.layer.shadowColor = borderShadow.shadowColor.CGColor;
            self.layer.shadowOpacity = borderShadow.shadowOpacity;
            self.layer.shadowRadius = borderShadow.shadowRadius;
            self.layer.shadowOffset = borderShadow.shadowOffset;
        }
    }
    
    return self;
}

- (void)setOpaque:(BOOL)opaque{
    
}

- (void)setBackgroundColor:(UIColor *)backgroundColor{
    
}

- (void)setCornerRadius:(CGFloat)cornerRadius{
    if(_cornerRadius != cornerRadius){
        _cornerRadius = cornerRadius;
        
        [self updateContentInsets];
        [self updateFrame];
    }
}

- (void)setBubbleColor:(UIColor *)bubbleColor forState:(UIControlState)state{
    if(bubbleColor){
        _stateColors[@(state)] = bubbleColor;
    }else{
        [_stateColors removeObjectForKey:@(state)];
    }
    
    if(state == UIControlStateNormal){
        [self setNeedsDisplay];
    }
}

- (void)setHighlighted:(BOOL)highlighted{
    if(self.isAdjustsColorWhenHighlighted && self.isHighlighted != highlighted){
        [super setHighlighted:highlighted];
        
        if(_stateColors[@(UIControlStateHighlighted)]){
            [self setNeedsDisplay];
        }
    }
}

- (void)updateContentInsets{
    CGFloat edgeMargin = 5.0;
    switch (_arrowDirection) {
        case CXActionBubbleViewArrowDirectionTop:{
            _contentInsets.top = _arrowSize + edgeMargin;
            _contentInsets.left = MAX(_cornerRadius - edgeMargin, edgeMargin);
            _contentInsets.bottom = edgeMargin;
            _contentInsets.right = MAX(_cornerRadius - edgeMargin, edgeMargin);
        }
            break;
        case CXActionBubbleViewArrowDirectionLeft:{
            _contentInsets.top = edgeMargin;
            _contentInsets.left = _arrowSize + MAX(_cornerRadius - edgeMargin, edgeMargin);
            _contentInsets.bottom = edgeMargin;
            _contentInsets.right = MAX(_cornerRadius - edgeMargin, edgeMargin);
        }
            break;
        case CXActionBubbleViewArrowDirectionBottom:{
            _contentInsets.top = edgeMargin;
            _contentInsets.left = MAX(_cornerRadius - edgeMargin, edgeMargin);
            _contentInsets.bottom = _arrowSize + edgeMargin;
            _contentInsets.right = MAX(_cornerRadius - edgeMargin, edgeMargin);
        }
            break;
        case CXActionBubbleViewArrowDirectionRight:{
            _contentInsets.top = edgeMargin;
            _contentInsets.left = MAX(_cornerRadius - edgeMargin, edgeMargin);
            _contentInsets.bottom =  edgeMargin;
            _contentInsets.right = _arrowSize + MAX(_cornerRadius - edgeMargin, edgeMargin);
        }
            break;
        default:
            break;
    }
    
    _contentInsets.top = _contentInsets.top + self.layer.shadowRadius;
    _contentInsets.left = _contentInsets.left + self.layer.shadowRadius;
    _contentInsets.bottom = _contentInsets.bottom + self.layer.shadowRadius;
    _contentInsets.right = _contentInsets.right + self.layer.shadowRadius;
}

- (void)setContentSize:(CGSize)contentSize{
    _contentSize = contentSize;
    
    [self updateFrame];
}

- (void)updateFrame{
    _contentView.frame = (CGRect){_contentInsets.left, _contentInsets.top, _contentSize};
    
    CGRect frame = self.frame;
    frame.size.width = _contentSize.width + _contentInsets.left + _contentInsets.right;
    frame.size.height = _contentSize.height + _contentInsets.top + _contentInsets.bottom;
    
    _visibleSize = frame.size;
    if(_arrowDirection == CXActionBubbleViewArrowDirectionTop || _arrowDirection == CXActionBubbleViewArrowDirectionBottom){
        _visibleSize.height = _visibleSize.height - _arrowSize;
    }else{
        _visibleSize.width = _visibleSize.width - _arrowSize;
    }
    
    if(!CGRectEqualToRect(self.frame, frame)){
        [self setFrame:frame];
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect{
    CGContextClearRect(UIGraphicsGetCurrentContext(), rect);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect frame = rect;
    frame.origin.x = self.layer.shadowRadius;
    frame.origin.y = self.layer.shadowRadius;
    frame.size.width = frame.size.width - self.layer.shadowRadius * 2;
    frame.size.height = frame.size.height - self.layer.shadowRadius * 2;
    
    [self drawContentBackground:frame context:context];
}

- (void)drawContentBackground:(CGRect)frame context:(CGContextRef)context{
    CGFloat locations[] = {1.0};
    CGFloat components[] = {0.0, 0.0, 0.0, 1.0};
    
    UIColor *fillColor = _stateColors[@(UIControlStateNormal)];
    if(self.isHighlighted){
        fillColor = _stateColors[@(UIControlStateHighlighted)];
    }
    
    if(fillColor == nil){
        fillColor = [UIColor blackColor];
    }
    
    [fillColor getRed:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];
    
    CGFloat frame_x0 = CGRectGetMinX(frame);
    CGFloat frame_x1 = CGRectGetMaxX(frame);
    CGFloat frame_y0 = CGRectGetMinY(frame);
    CGFloat frame_y1 = CGRectGetMaxY(frame);
    
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    CGFloat offset = _arrowSize * 0.25;
    switch (_arrowDirection) {
        case CXActionBubbleViewArrowDirectionTop:{
            CGFloat arrow_x0 = CGRectGetMidX(frame) - _arrowSize;
            CGFloat arrow_x1 = CGRectGetMidX(frame) + _arrowSize;
            CGFloat arrow_y0 = frame_y0;
            CGFloat arrow_y1 = frame_y0 + _arrowSize + offset;
            
            [arrowPath moveToPoint:(CGPoint){CGRectGetMidX(frame), arrow_y0}];
            [arrowPath addLineToPoint:(CGPoint){arrow_x1, arrow_y1}];
            [arrowPath addLineToPoint:(CGPoint){arrow_x0, arrow_y1}];
            [arrowPath addLineToPoint:(CGPoint){CGRectGetMidX(frame), arrow_y0}];
            
            frame_y0 = frame_y0 + _arrowSize;
        }
            break;
        case CXActionBubbleViewArrowDirectionBottom:{
            CGFloat arrowX0 = CGRectGetMidX(frame) - _arrowSize;
            CGFloat arrowX1 = CGRectGetMidX(frame) + _arrowSize;
            CGFloat arrowY0 = frame_y1 - _arrowSize - offset;
            CGFloat arrowY1 = frame_y1;
            
            [arrowPath moveToPoint:(CGPoint){CGRectGetMidX(frame), arrowY1}];
            [arrowPath addLineToPoint:(CGPoint){arrowX1, arrowY0}];
            [arrowPath addLineToPoint:(CGPoint){arrowX0, arrowY0}];
            [arrowPath addLineToPoint:(CGPoint){CGRectGetMidX(frame), arrowY1}];
            
            frame_y1 = frame_y1 - _arrowSize;
        }
            break;
        case CXActionBubbleViewArrowDirectionLeft:{
            CGFloat arrow_x0 = frame_x0;
            CGFloat arrow_x1 = frame_x0 + _arrowSize + offset;
            CGFloat arrow_y0 = CGRectGetMidY(frame) - _arrowSize;
            CGFloat arrow_y1 = CGRectGetMidY(frame) + _arrowSize;
            
            [arrowPath moveToPoint:(CGPoint){arrow_x0, CGRectGetMidY(frame)}];
            [arrowPath addLineToPoint:(CGPoint){arrow_x1, arrow_y0}];
            [arrowPath addLineToPoint:(CGPoint){arrow_x1, arrow_y1}];
            [arrowPath addLineToPoint:(CGPoint){arrow_x0, CGRectGetMidY(frame)}];
            
            frame_x0 = frame_x0 + _arrowSize;
        }
            break;
        case CXActionBubbleViewArrowDirectionRight:{
            CGFloat arrow_x0 = frame_x1;
            CGFloat arrow_x1 = frame_x1 - _arrowSize - offset;
            CGFloat arrow_y0 = CGRectGetMidY(frame) - _arrowSize;
            CGFloat arrow_y1 = CGRectGetMidY(frame) + _arrowSize;
            
            [arrowPath moveToPoint:(CGPoint){arrow_x0, CGRectGetMidY(frame)}];
            [arrowPath addLineToPoint:(CGPoint){arrow_x1, arrow_y0}];
            [arrowPath addLineToPoint:(CGPoint){arrow_x1, arrow_y1}];
            [arrowPath addLineToPoint:(CGPoint){arrow_x0, CGRectGetMidY(frame)}];
            
            frame_x1 = frame_x1 - _arrowSize;
        }
            break;
        default:
            break;
    }
    
    [fillColor set];
    [arrowPath fill];
    
    CGRect borderRect = (CGRect){frame_x0, frame_y0, frame_x1 - frame_x0, frame_y1 - frame_y0};
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:borderRect cornerRadius:self.cornerRadius];
    [borderPath appendPath:arrowPath];
    borderPath.lineWidth = 0.5;
    self.layer.shadowPath = borderPath.CGPath;
    [borderPath addClip];
    
    size_t count = sizeof(locations) / sizeof(locations[0]);
    [self fillBackgroundColorForRect:borderRect context:context components:components locations:locations count:count];
}

- (void)fillBackgroundColorForRect:(CGRect)rect context:(CGContextRef)context components:(const CGFloat[])components locations:(const CGFloat[])locations count:(size_t)count{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, count);
    CGColorSpaceRelease(colorSpace);
    
    CGPoint endPoint;
    if(_arrowDirection == CXActionBubbleViewArrowDirectionLeft || _arrowDirection == CXActionBubbleViewArrowDirectionRight){
        endPoint = (CGPoint){CGRectGetMaxX(rect), rect.origin.y};
    }else{
        endPoint = (CGPoint){rect.origin.x, CGRectGetMaxY(rect)};
    }
    
    CGContextDrawLinearGradient(context, gradient, rect.origin, endPoint, 0);
    CGGradientRelease(gradient);
}

@end

@implementation CXActionBubbleViewBorderShadow

+ (instancetype)defaultBorderShadow{
    CXActionBubbleViewBorderShadow *borderShadow = [[CXActionBubbleViewBorderShadow alloc] init];
    borderShadow.shadowColor = [UIColor blackColor];
    borderShadow.shadowRadius = 1.0;
    borderShadow.shadowOpacity = 0.25;
    borderShadow.shadowOffset = CGSizeZero;
    return borderShadow;
}

@end
