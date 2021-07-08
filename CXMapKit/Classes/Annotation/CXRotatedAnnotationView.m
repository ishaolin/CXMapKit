//
//  CXRotatedAnnotationView.m
//  Pods
//
//  Created by wshaolin on 2018/4/19.
//

#import "CXRotatedAnnotationView.h"

@interface CXRotatedAnnotationView () {
    UIImageView *_rotatedView;
}

@end

@implementation CXRotatedAnnotationView

- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]){
        self.imageView.hidden = YES;
        _rotateEnabled = YES;
        
        _rotatedView = [[UIImageView alloc] init];
        [self addSubview:_rotatedView];
        _marker = _rotatedView;
    }
    
    return self;
}

- (void)setImage:(UIImage *)image{
    [super setImage:image];
    
    _rotatedView.image = image;
}

- (void)setRotationDegree:(CGFloat)rotationDegree{
    [self setRotationDegree:rotationDegree animated:NO];
}

- (void)setRotationDegree:(CGFloat)rotationDegree animated:(BOOL)animated{
    [self setRotationDegree:rotationDegree duration:0.25 animated:animated];
}

- (void)setRotationDegree:(CGFloat)rotationDegree duration:(NSTimeInterval)duration animated:(BOOL)animated{
    if(_rotationDegree == rotationDegree){
        return;
    }
    _rotationDegree = rotationDegree;
    
    if(!_rotateEnabled){
        return;
    }
    
    void (^animations)(void) = ^{
        self->_rotatedView.transform = CGAffineTransformMakeRotation(self->_rotationDegree * M_PI / 180.0);
    };
    
    if(animated){
        [UIView animateWithDuration:duration animations:animations];
    }else{
        animations();
    }
}

- (void)setBounds:(CGRect)bounds{
    [super setBounds:bounds];
    
    CGFloat rotatedView_W = _rotatedView.image.size.width;
    CGFloat rotatedView_H = _rotatedView.image.size.height;
    CGFloat rotatedView_X = (CGRectGetWidth(bounds) - rotatedView_W) * 0.5;
    CGFloat rotatedView_Y = CGRectGetHeight(bounds) - rotatedView_H;
    _rotatedView.frame = (CGRect){rotatedView_X, rotatedView_Y, rotatedView_W, rotatedView_H};
}

@end
