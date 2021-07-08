//
//  CXMapNaviViewDelegate.h
//  Pods
//
//  Created by wshaolin on 2019/4/12.
//

#import <Foundation/Foundation.h>
#import "CXMapKitDefines.h"

@class UIView;

@protocol CXMapNaviViewDelegate <NSObject>

@optional

- (void)naviView:(UIView *)naviView didChangeShowMode:(CXMapNaviShowMode)showMode naviType:(CXMapNaviType)naviType;
- (void)naviViewDidLayoutSubviews:(UIView *)naviView naviType:(CXMapNaviType)naviType;
- (void)naviView:(UIView *)naviView closeForNaviType:(CXMapNaviType)naviType completion:(void (^)(BOOL finished))completion;

@end
