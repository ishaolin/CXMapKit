//
//  CXMapRoutePreferenceView.m
//  Pods
//
//  Created by wshaolin on 2019/4/14.
//

#import "CXMapRoutePreferenceView.h"
#import "CXMapRouteRequestOption.h"
#import "CXMapKitDefines.h"

typedef NS_ENUM(NSInteger, CXMapRoutePreferenceType){
    CXMapRoutePreferenceAvoidCongestion = 0,    // 躲避拥堵
    CXMapRoutePreferenceAvoidCost,              // 避免收费
    CXMapRoutePreferenceAvoidHighway,           // 不走高速
    CXMapRoutePreferencePrioritiseHighway       // 高速优先
};

@interface CXMapRoutePreferenceView () {
    UILabel *_textLabel;
    UIImageView *_imageView;
}

@end

@implementation CXMapRoutePreferenceView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = CXHexIColor(0xFFFFFF);
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.textAlignment = NSTextAlignmentLeft;
        _textLabel.font = CX_PingFangSC_RegularFont(13.0);
        _textLabel.textColor = CXHexIColor(0x333333);
        _textLabel.text = @"智能推荐";
        [self addSubview:_textLabel];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.image = CX_MAPKIT_IMAGE(@"map_route_preference_arrow");
        [self addSubview:_imageView];
        
        [self addTarget:self action:@selector(handleActionForPreferenceView:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

- (void)handleActionForPreferenceView:(CXMapRoutePreferenceView *)preferenceView{
    CXMapRoutePreferencePanel *preferencePanel = [[CXMapRoutePreferencePanel alloc] init];
    [preferencePanel showWithPreferenceView:preferenceView];
}

- (void)setPreference:(CXMapRoutePreference *)preference{
    if(_preference && [_preference isEqualToPreference:preference]){
        return;
    }
    _preference = preference;
    
    NSString *text = @"";
    if(preference.avoidCongestion){
        text = [text stringByAppendingString:@"，躲避拥堵"];
    }
    
    if(preference.avoidCost){
        text = [text stringByAppendingString:@"，避免收费"];
    }
    
    if(preference.avoidHighway){
        text = [text stringByAppendingString:@"，不走高速"];
    }
    
    if(preference.prioritiseHighway){
        text = [text stringByAppendingString:@"，高速优先"];
    }
    
    if(CXStringIsEmpty(text)){
        _textLabel.text = @"智能推荐";
    }else{
        _textLabel.text = [text substringFromIndex:1];
    }
    
    if(_preference && [self.delegate respondsToSelector:@selector(routePreferenceView:didChangePreference:)]){
        [self.delegate routePreferenceView:self didChangePreference:_preference];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat textLabel_W = 52.0;
    CGFloat textLabel_H = 20.0;
    CGFloat textLabel_X = 5.0;
    CGFloat textLabel_Y = (CGRectGetHeight(self.frame) - textLabel_H) * 0.5;
    _textLabel.frame = (CGRect){textLabel_X, textLabel_Y, textLabel_W, textLabel_H};
    
    CGFloat imageView_W = 13.0;
    CGFloat imageView_H = imageView_W;
    CGFloat imageView_X = CGRectGetWidth(self.frame) - imageView_W - textLabel_X;
    CGFloat imageView_Y = (CGRectGetHeight(self.frame) - imageView_H) * 0.5;
    _imageView.frame = (CGRect){imageView_X, imageView_Y, imageView_W, imageView_H};
    
    [self cx_roundedCornerRadii:2.0];
}

@end

@interface CXMapRoutePreferencePanel () {
    NSMutableArray<CXBlockLayoutButton *> *_preferenceItems;
    NSMutableArray<UIView *> *_lineViews;
}

@property (nonatomic, weak) CXMapRoutePreferenceView *preferenceView;

@end

@implementation CXMapRoutePreferencePanel

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor whiteColor];
        self.animationType = CXActionPanelAnimationCustom;
        self.panelSize = CGSizeMake(290.0, 70.0);
        
        _preferenceItems = [NSMutableArray array];
        _lineViews = [NSMutableArray array];
        
        NSArray<NSString *> *preferenceNames = @[@"躲避拥堵", @"避免收费", @"不走高速", @"高速优先"];
        NSArray<NSString *> *preferenceNormalImages = @[@"map_navi_avoid_congestion_0",
                                                        @"map_navi_avoid_cost_0",
                                                        @"map_navi_avoid_highway_0",
                                                        @"map_navi_prioritise_highway_0"];
        NSArray<NSString *> *preferenceSelectedImages = @[@"map_navi_avoid_congestion_1",
                                                          @"map_navi_avoid_cost_1",
                                                          @"map_navi_avoid_highway_1",
                                                          @"map_navi_prioritise_highway_1"];
        [preferenceNames enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CXBlockLayoutButton *preferenceItem = [CXBlockLayoutButton buttonWithType:UIButtonTypeCustom];
            preferenceItem.enableHighlighted = NO;
            preferenceItem.titleLabel.font = CX_PingFangSC_RegularFont(12.0);
            preferenceItem.titleLabel.textAlignment = NSTextAlignmentCenter;
            [preferenceItem setTitle:obj forState:UIControlStateNormal];
            [preferenceItem setTitleColor:CXHexIColor(0x333333) forState:UIControlStateNormal];
            [preferenceItem setTitleColor:CXHexIColor(0x59D8FF) forState:UIControlStateSelected];
            [preferenceItem setImage:CX_MAPKIT_IMAGE(preferenceNormalImages[idx]) forState:UIControlStateNormal];
            [preferenceItem setImage:CX_MAPKIT_IMAGE(preferenceSelectedImages[idx]) forState:UIControlStateSelected];
            [preferenceItem addTarget:self action:@selector(handleActionForPreferenceItem:) forControlEvents:UIControlEventTouchUpInside];
            preferenceItem.tag = idx;
            preferenceItem.combinedRectBlock = ^CXButtonCombinedRect(CXBlockLayoutButton *button, CGRect contentRect) {
                CGFloat title_H = 20.0;
                
                CGFloat image_W = 30.0;
                CGFloat image_H = 31.0;
                CGFloat image_X = (CGRectGetWidth(contentRect) - image_W) * 0.5;
                CGFloat image_Y = (CGRectGetHeight(contentRect) - image_H - title_H) * 0.5;
                CGRect imageRect = (CGRect){image_X, image_Y, image_W, image_H};
                
                CGFloat title_X = 0;
                CGFloat title_W = CGRectGetWidth(contentRect);
                CGFloat title_Y = CGRectGetMaxY(imageRect);
                CGRect titleRect = (CGRect){title_X, title_Y, title_W, title_H};
                
                return CXButtonCombinedRectMake(imageRect, titleRect);
            };
            [self addSubview:preferenceItem];
            [self->_preferenceItems addObject:preferenceItem];
            
            if(idx > 0){
                UIView *lineView = [[UIView alloc] init];
                lineView.backgroundColor = CXHexIColor(0xECECEC);
                [self addSubview:lineView];
                [self->_lineViews addObject:lineView];
            }
        }];
    }
    
    return self;
}

- (void)showWithPreferenceView:(CXMapRoutePreferenceView *)preferenceView{
    self.preferenceView = preferenceView;
    _preference = [preferenceView.preference copyPreference] ?: [[CXMapRoutePreference alloc] init];
    [self setUpdatePreferenceItemState];
    
    [self showInView:preferenceView];
}

- (void)handleActionForPreferenceItem:(CXBlockLayoutButton *)preferenceItem{
    switch (preferenceItem.tag) {
        case CXMapRoutePreferenceAvoidCongestion:{
            _preference.avoidCongestion = !preferenceItem.isSelected;
        }
            break;
        case CXMapRoutePreferenceAvoidCost:{
            _preference.avoidCost = !preferenceItem.isSelected;
            _preference.prioritiseHighway = NO;
        }
            break;
        case CXMapRoutePreferenceAvoidHighway:{
            _preference.avoidHighway = !preferenceItem.isSelected;
            _preference.prioritiseHighway = NO;
        }
            break;
        case CXMapRoutePreferencePrioritiseHighway:{
            _preference.prioritiseHighway = !preferenceItem.isSelected;
            if(_preference.prioritiseHighway){
                _preference.avoidCost = NO;
                _preference.avoidHighway = NO;
            }
        }
            break;
        default:
            break;
    }
    
    [self setUpdatePreferenceItemState];
}

- (void)setUpdatePreferenceItemState{
    [_preferenceItems enumerateObjectsUsingBlock:^(CXBlockLayoutButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        switch (idx) {
            case CXMapRoutePreferenceAvoidCongestion:{
                obj.selected = self->_preference.avoidCongestion;
            }
                break;
            case CXMapRoutePreferenceAvoidCost:{
                obj.selected = self->_preference.avoidCost;
            }
                break;
            case CXMapRoutePreferenceAvoidHighway:{
                obj.selected = self->_preference.avoidHighway;
            }
                break;
            case CXMapRoutePreferencePrioritiseHighway:{
                obj.selected = self->_preference.prioritiseHighway;
            }
                break;
            default:
                break;
        }
    }];
}

- (CXActionAnimationBlock)showAnimationWithSuperView:(UIView *)superView{
    CGRect rect = [self.preferenceView.superview convertRect:self.preferenceView.frame toView:superView];
    CGFloat x = CGRectGetMinX(self.preferenceView.frame);
    CGFloat y = CGRectGetMinY(rect) - self.panelSize.height - 10.0;
    self.frame = (CGRect){x, y, self.panelSize};
    
    return NULL;
}

- (CXActionAnimationBlock)dismissAnimationWithSuperView:(UIView *)superView{
    return NULL;
}

- (void)willDismiss{
    self.preferenceView.preference = _preference;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if(CXArrayIsEmpty(_preferenceItems)){
        return;
    }
    
    CGFloat lineView_W = 0.5;
    CGFloat lineView_Y = 13.0;
    CGFloat lineView_H = CGRectGetHeight(self.bounds) - lineView_Y * 2;
    
    CGFloat preferenceItem_W = (CGRectGetWidth(self.bounds) - lineView_W * _lineViews.count) / _preferenceItems.count;
    CGFloat preferenceItem_H = CGRectGetHeight(self.bounds);
    CGFloat preferenceItem_Y = 0;
    [_preferenceItems enumerateObjectsUsingBlock:^(CXBlockLayoutButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat preferenceItem_X = (preferenceItem_W + lineView_W) * idx;
        obj.frame = (CGRect){preferenceItem_X, preferenceItem_Y, preferenceItem_W, preferenceItem_H};
        
        if(idx < self->_lineViews.count){
            UIView *lineView = self->_lineViews[idx];
            CGFloat lineView_X = CGRectGetMaxX(obj.frame);
            lineView.frame = (CGRect){lineView_X, lineView_Y, lineView_W, lineView_H};
        }
    }];
    
    [self cx_roundedCornerRadii:4.0];
}

@end
