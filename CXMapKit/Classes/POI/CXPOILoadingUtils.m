//
//  CXPOILoadingUtils.m
//  Pods
//
//  Created by wshaolin on 2019/4/14.
//

#import "CXPOILoadingUtils.h"
#import <CXUIKit/CXUIKit.h>

#define CX_POI_LOADING_INDICATOR_VIEW   1000
#define CX_POI_LOADING_INDICATOR_LABEL  1001
#define CX_POI_LOADING_RETRY_BUTTON     1002

@implementation CXPOILoadingUtils

+ (void)setNeedsLoadingForView:(UIView *)view
                           msg:(NSString *)msg
                        origin:(CGPoint)origin{
    if(!view){
        return;
    }
    
    [self setNeedsDismissForView:view];
    
    CGFloat activityIndicatorView_X = origin.x;
    CGFloat activityIndicatorView_Y = origin.y;
    CGFloat activityIndicatorView_W = 40.0;
    CGFloat activityIndicatorView_H = activityIndicatorView_W;
    UIActivityIndicatorView *activityIndicatorView = [UIActivityIndicatorView grayIndicatorView];
    activityIndicatorView.frame = (CGRect){activityIndicatorView_X, activityIndicatorView_Y, activityIndicatorView_W, activityIndicatorView_H};
    activityIndicatorView.tag = CX_POI_LOADING_INDICATOR_VIEW;
    [view addSubview:activityIndicatorView];
    
    CGFloat activityIndicatorLabel_X = CGRectGetMaxX(activityIndicatorView.frame);
    CGFloat activityIndicatorLabel_Y = activityIndicatorView_Y;
    CGFloat activityIndicatorLabel_H = activityIndicatorView_H;
    CGFloat activityIndicatorLabel_W = view.bounds.size.width - activityIndicatorLabel_X - origin.x;
    UILabel *activityIndicatorLabel = [[UILabel alloc] init];
    activityIndicatorLabel.frame = (CGRect){activityIndicatorLabel_X, activityIndicatorLabel_Y, activityIndicatorLabel_W, activityIndicatorLabel_H};
    activityIndicatorLabel.font = CX_PingFangSC_RegularFont(16.0);
    activityIndicatorLabel.textColor = CXHexIColor(0x999999);
    activityIndicatorLabel.backgroundColor = [UIColor clearColor];
    activityIndicatorLabel.text = msg;
    activityIndicatorLabel.tag = CX_POI_LOADING_INDICATOR_LABEL;
    [view addSubview:activityIndicatorLabel];
    
    [activityIndicatorView startAnimating];
}

+ (void)setNeedsFailedForView:(UIView *)view
                          msg:(NSString *)msg
                  retryTarget:(id)target
                       action:(SEL)action{
    if(!view){
        return;
    }
    
    [self setNeedsDismissForView:view];
    
    CGFloat retryButton_W = 200.0;
    CGFloat retryButton_H = 80.0;
    CGFloat retryButton_X = (view.bounds.size.width - retryButton_W) * 0.5;
    CGFloat retryButton_Y = 60.0;
    if([view isKindOfClass:[UITableView class]]){
        UITableView *tableView = (UITableView *)view;
        retryButton_Y += tableView.tableHeaderView.frame.size.height;
    }
    
    UIButton *retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    retryButton.frame = (CGRect){retryButton_X, retryButton_Y, retryButton_W, retryButton_H};
    retryButton.titleLabel.font = CX_PingFangSC_RegularFont(16.0);
    retryButton.titleLabel.numberOfLines = 0;
    [retryButton setTitle:msg forState:UIControlStateNormal];
    [retryButton setTitleColor:CXHexIColor(0x999999) forState:UIControlStateNormal];
    retryButton.backgroundColor = [UIColor clearColor];
    retryButton.tag = CX_POI_LOADING_RETRY_BUTTON;
    if(target && action){
        [retryButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    
    [view addSubview:retryButton];
}

+ (void)setNeedsDismissForView:(UIView *)view{
    if(!view){
        return;
    }
    
    [view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj isKindOfClass:[UIActivityIndicatorView class]] && obj.tag == CX_POI_LOADING_INDICATOR_VIEW){
            [obj removeFromSuperview];
        }
        
        if([obj isKindOfClass:[UILabel class]] && obj.tag == CX_POI_LOADING_INDICATOR_LABEL){
            [obj removeFromSuperview];
        }
        
        if([obj isKindOfClass:[UIButton class]] && obj.tag == CX_POI_LOADING_RETRY_BUTTON){
            [obj removeFromSuperview];
        }
    }];
}

@end
