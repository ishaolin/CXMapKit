//
//  CXMapSpeedView.m
//  Pods
//
//  Created by lcc on 2018/6/28.
//

#import "CXMapSpeedView.h"
#import <CXUIKit/CXUIKit.h>

@interface CXMapSpeedView() {
    UILabel *_speedLabel;
    UILabel *_unitLabel;
}

@end

@implementation CXMapSpeedView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = CXHexIColor(0xFFFFFF);
        
        _speedLabel = [[UILabel alloc] init];
        _speedLabel.font = CX_PingFangSC_SemiboldFont(24.0);
        _speedLabel.textAlignment = NSTextAlignmentCenter;
        _speedLabel.textColor = CXHexIColor(0x1DBEFF);
        [self addSubview:_speedLabel];
        
        _unitLabel = [[UILabel alloc] init];
        _unitLabel.font = CX_PingFangSC_RegularFont(10.0);
        _unitLabel.textAlignment = NSTextAlignmentCenter;
        _unitLabel.textColor = CXHexIColor(0x1DBEFF);
        _unitLabel.text = @"km/h";
        _unitLabel.numberOfLines = 2;
        
        [self addSubview:_unitLabel];
    }
    
    return self;
}

- (void)setSpeed:(NSString *)speed{
    _speed = speed;
    _speedLabel.text = speed;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat speedLabel_X = 0;
    CGFloat speedLabel_Y = 10.0;
    CGFloat speedLabel_W = CGRectGetWidth(self.frame);
    CGFloat speedLabel_H = 33.0;
    _speedLabel.frame = (CGRect){speedLabel_X, speedLabel_Y, speedLabel_W, speedLabel_H};
    
    CGFloat unitLabel_W = 26.0;
    CGFloat unitLabel_H = 12.0;
    CGFloat unitLabel_X = (CGRectGetWidth(self.frame) - unitLabel_W) * 0.5;
    CGFloat unitLabel_Y = CGRectGetMaxY(_speedLabel.frame);
    _unitLabel.frame = (CGRect){unitLabel_X, unitLabel_Y, unitLabel_W, unitLabel_H};
    
    [self cx_roundedCornerRadii:CGRectGetHeight(self.frame) * 0.5];
}

@end
