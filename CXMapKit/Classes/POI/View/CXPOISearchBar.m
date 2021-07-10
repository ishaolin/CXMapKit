//
//  CXPOISearchBar.m
//  Pods
//
//  Created by wshaolin on 2019/4/14.
//

#import "CXPOISearchBar.h"
#import "CXImageUtils.h"
#import <CXFoundation/CXFoundation.h>

@interface CXPOISearchBar() <UITextFieldDelegate> {
    UIView *_contentView;
    UIButton *_leftButton;
    UIView *_textFieldBackgroundView;
    UITextField *_textField;
    UIButton *_rightButton;
    NSString *_text;
    
    CXPOISearchBarRightStyle _rightStyle;
}

@end

@implementation CXPOISearchBar

- (instancetype)init{
    return [self initWithRightStyle:CXPOISearchBarRightStyleNone];
}

- (instancetype)initWithRightStyle:(CXPOISearchBarRightStyle)rightStyle{
    if(self = [super init]){
        self.backgroundColor = [UIColor whiteColor];
        _rightStyle = rightStyle;
        
        _contentView = [[UIView alloc] init];
        [self addSubview:_contentView];
        
        _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CXNavigationConfig *config =  CXNavigationConfigDefault();
        [_leftButton setImage:[CX_UIKIT_IMAGE(@"ui_navigation_bar_back") cx_imageForTintColor:[config itemTitleColorForState:UIControlStateNormal]] forState:UIControlStateNormal];
        [_leftButton setImage:[CX_UIKIT_IMAGE(@"ui_navigation_bar_back") cx_imageForTintColor:[config itemTitleColorForState:UIControlStateHighlighted]] forState:UIControlStateHighlighted];
        [_leftButton addTarget:self action:@selector(handleActionForLeftButton:) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:_leftButton];
        
        _textFieldBackgroundView = [[UIView alloc] init];
        _textFieldBackgroundView.backgroundColor = CXHexIColor(0xF9F9F9);
        [_contentView addSubview:_textFieldBackgroundView];
        
        _textField = [[UITextField alloc] init];
        _textField.enablesReturnKeyAutomatically = YES;
        _textField.delegate = self;
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_textField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
        [_textFieldBackgroundView addSubview:_textField];
        
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightButton.titleLabel setFont:CX_PingFangSC_RegularFont(14.0)];
        [_rightButton setTitleColor:CXHexIColor(0xBAD3DA) forState:UIControlStateDisabled];
        [_rightButton setTitleColor:CXHexIColor(0x59D8FF) forState:UIControlStateNormal];
        [_rightButton setTitleColor:CXHexIColor(0x5CC5E6) forState:UIControlStateHighlighted];
        if(_rightStyle == CXPOISearchBarRightStyleSearch){
            _rightButton.enabled = NO;
            [_rightButton setTitle:@"搜索" forState:UIControlStateNormal];
        }else if(_rightStyle == CXPOISearchBarRightStyleCross){
            [_rightButton setImage:[CX_UIKIT_IMAGE(@"ui_page_close") cx_imageForTintColor:[config itemTitleColorForState:UIControlStateNormal]] forState:UIControlStateNormal];
            [_rightButton setImage:[CX_UIKIT_IMAGE(@"ui_page_close") cx_imageForTintColor:[config itemTitleColorForState:UIControlStateHighlighted]] forState:UIControlStateHighlighted];
        }else{
            _rightButton.hidden = YES;
        }
        [_rightButton addTarget:self action:@selector(handleActionForRightButton:) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:_rightButton];
        
        self.font = CX_PingFangSC_RegularFont(13.0);
        self.barTintColor = [CXHexIColor(0x333333) colorWithAlphaComponent:0.8];
        self.barTextColor = CXHexIColor(0x333333);
        self.placeholdTextColor = CXHexIColor(0x999999);
    }
    
    return self;
}

- (BOOL)isFirstResponder{
    return [_textField isFirstResponder];
}

- (BOOL)becomeFirstResponder{
    return [_textField becomeFirstResponder];
}

- (void)setSearchText:(NSString *)searchText{
    _textField.text = searchText;
    
    [self setSearchButtonEnabledIfNeed];
}

- (NSString *)searchText{
    return _textField.text;
}

- (void)setFont:(UIFont *)font{
    _font = font;
    _textField.font = _font;
    
    [self setAttributedPlaceholder];
}

- (void)setPlaceholder:(NSString *)placeholder{
    _placeholder = placeholder;
    
    [self setAttributedPlaceholder];
}

- (void)setPlaceholdTextColor:(UIColor *)placeholdTextColor {
    _placeholdTextColor = placeholdTextColor;
    
    [self setAttributedPlaceholder];
}

- (void)setAttributedPlaceholder{
    if(CXStringIsEmpty(_placeholder)){
        return;
    }
    
    if(!_placeholdTextColor){
        return;
    }
    
    NSDictionary<NSAttributedStringKey, id> *attributes = nil;
    if(_font){
        attributes = @{NSForegroundColorAttributeName : _placeholdTextColor, NSFontAttributeName : _font};
    }else{
        attributes = @{NSForegroundColorAttributeName : _placeholdTextColor};
    }
    _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_placeholder attributes:attributes];
}

- (void)setBarTextColor:(UIColor *)barTextColor{
    _barTextColor = barTextColor;
    _textField.textColor = _barTextColor;
}

- (void)setBarTintColor:(UIColor *)barTintColor{
    _barTintColor = barTintColor;
    _textField.tintColor = _barTintColor;
}

- (void)setReturnKeyType:(UIReturnKeyType)returnKeyType{
    _returnKeyType = returnKeyType;
    _textField.returnKeyType = returnKeyType;
}

- (void)setSearchButtonEnabledIfNeed{
    if(_rightStyle == CXPOISearchBarRightStyleSearch){
        _rightButton.enabled = !CXStringIsEmpty(_textField.text);
    }
}

- (void)handleActionForLeftButton:(UIButton *)leftButton{
    if([self.delegate respondsToSelector:@selector(searchBarDidGoback:)]){
        [self.delegate searchBarDidGoback:self];
    }
}

- (void)handleActionForRightButton:(UIButton *)rightButton{
    if(_rightStyle == CXPOISearchBarRightStyleSearch) {
        if([self.delegate respondsToSelector:@selector(searchBarDidSearch:)]){
            [self.delegate searchBarDidSearch:self];
        }
    }else if(_rightStyle == CXPOISearchBarRightStyleCross){
        if([self.delegate respondsToSelector:@selector(searchBarDidCancel:)]){
            [self.delegate searchBarDidCancel:self];
        }
    }
}

- (void)textFieldDidChanged:(UITextField *)textField{
    if([textField.text isEqualToString:_text]){
        return;
    }
    
    _text = textField.text;
    [self setSearchButtonEnabledIfNeed];
    
    if([self.delegate respondsToSelector:@selector(searchBar:didChangeContent:)]){
        [self.delegate searchBar:self didChangeContent:_text];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if([self.delegate respondsToSelector:@selector(searchBarShouldBeginEditing:)]){
        return [self.delegate searchBarShouldBeginEditing:self];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if([self.delegate respondsToSelector:@selector(searchBarShouldReturn:)]){
        return [self.delegate searchBarShouldReturn:self];
    }
    
    return YES;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat contentView_X = 0;
    CGFloat contentView_W = CGRectGetWidth(self.bounds);
    CGFloat contentView_Y = 20.0 + [UIScreen mainScreen].cx_safeAreaInsets.top;
    CGFloat contentView_H = CGRectGetHeight(self.bounds) - contentView_Y;
    _contentView.frame = (CGRect){contentView_X, contentView_Y, contentView_W, contentView_H};
    
    CGFloat leftButton_X = 5.0;
    CGFloat leftButton_W = 30.0;
    CGFloat leftButton_H = 35.0;
    CGFloat leftButton_Y = (contentView_H - leftButton_H) * 0.5;
    _leftButton.frame = (CGRect){leftButton_X, leftButton_Y, leftButton_W, leftButton_H};
    
    CGFloat rightButton_W = 0;
    if(_rightStyle == CXPOISearchBarRightStyleSearch){
        rightButton_W = 60.0;
    }else if(_rightStyle == CXPOISearchBarRightStyleCross){
        rightButton_W = leftButton_W;
    }
    CGFloat rightButton_H = leftButton_H;
    CGFloat rightButton_X = contentView_W - rightButton_W - leftButton_X;
    CGFloat rightButton_Y = leftButton_Y;
    _rightButton.frame = (CGRect){rightButton_X, rightButton_Y, rightButton_W, rightButton_H};
    
    CGFloat textFieldBackgroundView_X = CGRectGetMaxX(_leftButton.frame) + 5.0;
    CGFloat textFieldBackgroundView_Y = leftButton_Y;
    CGFloat textFieldBackgroundView_W = rightButton_X - textFieldBackgroundView_X - 10.0;
    CGFloat textFieldBackgroundView_H = leftButton_H;
    _textFieldBackgroundView.frame = (CGRect){textFieldBackgroundView_X, textFieldBackgroundView_Y, textFieldBackgroundView_W, textFieldBackgroundView_H};
    [_textFieldBackgroundView cx_roundedCornerRadii:2.0];
    
    CGFloat textField_X = 10.0;
    CGFloat textField_Y = 0;
    CGFloat textField_W = CGRectGetWidth(_textFieldBackgroundView.frame) - textField_X;
    CGFloat textField_H = CGRectGetHeight(_textFieldBackgroundView.frame) - textField_Y * 2;
    _textField.frame = (CGRect){textField_X, textField_Y, textField_W, textField_H};
    [self cx_addShadowByOption:CXShadowBottom];
}

@end
