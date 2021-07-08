//
//  CXPOISearchBar.h
//  Pods
//
//  Created by wshaolin on 2019/4/14.
//

#import <CXUIKit/CXUIKit.h>

typedef NS_ENUM(NSInteger, CXPOISearchBarRightStyle){
    CXPOISearchBarRightStyleNone,
    CXPOISearchBarRightStyleCross,
    CXPOISearchBarRightStyleSearch
};

@class CXPOISearchBar;

@protocol CXPOISearchBarDelegate <NSObject>

@optional

- (void)searchBarDidGoback:(CXPOISearchBar *)searchBar;
- (void)searchBarDidSearch:(CXPOISearchBar *)searchBar;
- (void)searchBarDidCancel:(CXPOISearchBar *)searchBar;
- (void)searchBar:(CXPOISearchBar *)searchBar didChangeContent:(NSString *)content;

- (BOOL)searchBarShouldBeginEditing:(CXPOISearchBar *)searchBar;
- (BOOL)searchBarShouldReturn:(CXPOISearchBar *)searchBar;

@end

@interface CXPOISearchBar : UIView

@property (nonatomic, weak) id<CXPOISearchBarDelegate> delegate;
@property (nonatomic, copy) NSString *placeholder;              // 输入框占位符
@property (nonatomic, strong) UIColor *barTintColor;            // 输入框光标页面和取消按钮的文字颜色
@property (nonatomic, strong) UIColor *barTextColor;            // 输入框文字颜色
@property (nonatomic, strong) UIColor *placeholdTextColor;      // 输入框占位符颜色
@property (nonatomic, strong) UIFont *font;                     // 字体
@property (nonatomic, copy) NSString *searchText;               // 输入框内容
@property (nonatomic, assign) UIReturnKeyType returnKeyType;    // 键盘return键类型

- (instancetype)initWithRightStyle:(CXPOISearchBarRightStyle)rightStyle;

@end
