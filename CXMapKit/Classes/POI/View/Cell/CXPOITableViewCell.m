//
//  CXPOITableViewCell.m
//  Pods
//
//  Created by wshaolin on 2019/4/14.
//

#import "CXPOITableViewCell.h"
#import "CXMapPOIModel.h"
#import <CXFoundation/CXFoundation.h>
#import "CXMapKitDefines.h"

@interface CXPOITableViewCell() {
    UIImageView *_iconImageView;
    UILabel *_nameLabel;
    UILabel *_addressLabel;
    UIView *_bottomLineView;
}

@end

@implementation CXPOITableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithReuseIdentifier:reuseIdentifier]){
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.image = CX_MAPKIT_IMAGE(@"map_poi_list_logo");
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = CXHexIColor(0x333333);
        _nameLabel.font = CX_PingFangSC_RegularFont(13.0);
        
        _addressLabel = [[UILabel alloc] init];
        _addressLabel.textColor = CXHexIColor(0x999999);
        _addressLabel.font = CX_PingFangSC_RegularFont(12.0);
        
        _bottomLineView = [[UIView alloc] init];
        _bottomLineView.backgroundColor = [self.class highlightedColour];
        
        [self.contentView addSubview:_iconImageView];
        [self.contentView addSubview:_nameLabel];
        [self.contentView addSubview:_addressLabel];
        [self.contentView addSubview:_bottomLineView];
    }
    
    return self;
}

- (void)setPOIModel:(CXMapPOIModel *)POIModel{
    _POIModel = POIModel;
    
    _nameLabel.text = _POIModel.name;
    _addressLabel.text = [_POIModel fullAddress];
    
    [self setNeedsLayout];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat iconImageView_X = CX_MARGIN(15.0);
    CGFloat iconImageView_W = 21.0;
    CGFloat iconImageView_H = iconImageView_W;
    CGFloat iconImageView_Y = (CGRectGetHeight(self.bounds) - iconImageView_H) * 0.5;
    _iconImageView.frame = (CGRect){iconImageView_X, iconImageView_Y, iconImageView_W, iconImageView_H};
    
    CGFloat nameLabel_X = CGRectGetMaxX(_iconImageView.frame) + 10.0;
    CGFloat nameLabel_H = 19.0;
    CGFloat nameLabel_Y = 12.0;
    if(CXStringIsEmpty(_addressLabel.text)){
        nameLabel_Y = (CGRectGetHeight(self.bounds) - nameLabel_H) * 0.5;
    }
    CGFloat nameLabel_W = CGRectGetWidth(self.bounds) - nameLabel_X - iconImageView_X;
    _nameLabel.frame = CGRectMake(nameLabel_X, nameLabel_Y, nameLabel_W, nameLabel_H);
    
    CGFloat addressLabel_X = nameLabel_X;
    CGFloat addressLabel_Y = CGRectGetMaxY(_nameLabel.frame);
    CGFloat addressLabel_W = nameLabel_W;
    CGFloat addressLabel_H = 15.0;
    _addressLabel.frame = CGRectMake(addressLabel_X, addressLabel_Y, addressLabel_W, addressLabel_H);
    _addressLabel.hidden = CXStringIsEmpty(_addressLabel.text);
    
    CGFloat bottomLineView_X = 0;
    CGFloat bottomLineView_H = 0.5;
    CGFloat bottomLineView_W = CGRectGetWidth(self.bounds) - bottomLineView_X;
    CGFloat bottomLineView_Y = CGRectGetHeight(self.bounds) - bottomLineView_H;
    _bottomLineView.frame = CGRectMake(bottomLineView_X, bottomLineView_Y, bottomLineView_W, bottomLineView_H);
}

@end
