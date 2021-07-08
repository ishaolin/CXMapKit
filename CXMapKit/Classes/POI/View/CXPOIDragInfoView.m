//
//  CXPOIDragInfoView.m
//  Pods
//
//  Created by wshaolin on 2019/4/15.
//

#import "CXPOIDragInfoView.h"
#import <CXUIKit/CXUIKit.h>
#import "CXMapPOIModel.h"

@interface CXPOIDragInfoView () {
    UILabel *_nameLabel;
    UILabel *_addressLabel;
    UIButton *_confirmButton;
    
    CXMapPOIModel *_POIModel;
}

@end

@implementation CXPOIDragInfoView
- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = CXHexIColor(0xFFFFFF);
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = CX_PingFangSC_RegularFont(16.0);
        _nameLabel.textColor = CXHexIColor(0x333333);
        [self addSubview:_nameLabel];
        
        _addressLabel = [[UILabel alloc] init];
        _addressLabel.font = CX_PingFangSC_RegularFont(13.0);
        _addressLabel.textColor = CXHexIColor(0x999999);
        [self addSubview:_addressLabel];
        
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.titleLabel.font = CX_PingFangSC_RegularFont(16.0);
        [_confirmButton setTitleColor:CXHexIColor(0xFFFFFF) forState:UIControlStateNormal];
        [_confirmButton cx_setBackgroundColor:CXHexIColor(0x1DBEFF) forState:UIControlStateNormal];
        [_confirmButton cx_setBackgroundColor:CXHexIColor(0x00CDFF) forState:UIControlStateDisabled];
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(handleActionForConfirmButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_confirmButton];
    }
    
    return self;
}

- (void)willUpdateInfo{
    _nameLabel.text = @"位置获取中....";
    _addressLabel.text = nil;
    _confirmButton.enabled = NO;
}

- (void)setUpdateInfoWithPOIModel:(CXMapPOIModel *)POIModel{
    _POIModel = POIModel;
    
    if(_POIModel){
        _nameLabel.text = _POIModel.name;
        _addressLabel.text = _POIModel.address;
        _confirmButton.enabled = YES;
    }else{
        _nameLabel.text = @"获取位置信息失败.";
        _addressLabel.text = nil;
        _confirmButton.enabled = NO;
    }
}

- (void)handleActionForConfirmButton:(UIButton *)confirmButton{
    if([self.delegate respondsToSelector:@selector(POIDragInfoView:didConfirmWithPOIModel:)]){
        [self.delegate POIDragInfoView:self didConfirmWithPOIModel:_POIModel];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat nameLabel_X = CX_MARGIN(15.0);
    CGFloat nameLabel_H = _nameLabel.font.lineHeight;
    
    CGFloat addressLabel_X = nameLabel_X;
    CGFloat addressLabel_H = _addressLabel.font.lineHeight;
    
    CGFloat confirmButton_W = 70.0;
    CGFloat confirmButton_H = 32.0;
    CGFloat confirmButton_X = CGRectGetWidth(self.bounds) - confirmButton_W - nameLabel_X;
    CGFloat confirmButton_Y = (CGRectGetHeight(self.bounds) - confirmButton_H) * 0.5;
    _confirmButton.frame = (CGRect){confirmButton_X, confirmButton_Y, confirmButton_W, confirmButton_H};
    [_confirmButton cx_roundedCornerRadii:confirmButton_H * 0.5];
    
    CGFloat nameLabel_Y = (CGRectGetHeight(self.bounds) - nameLabel_H - addressLabel_H) * 0.5;
    CGFloat nameLabel_W = confirmButton_X - nameLabel_X;
    _nameLabel.frame = (CGRect){nameLabel_X, nameLabel_Y, nameLabel_W, nameLabel_H};
    
    CGFloat addressLabel_Y = CGRectGetMaxY(_nameLabel.frame);
    CGFloat addressLabel_W = nameLabel_W;
    _addressLabel.frame = (CGRect){addressLabel_X, addressLabel_Y, addressLabel_W, addressLabel_H};
}

@end
