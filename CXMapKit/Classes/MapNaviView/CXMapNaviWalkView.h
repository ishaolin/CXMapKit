//
//  CXMapNaviWalkView.h
//  CXMapKit
//
//  Created by lcc on 2018/6/19.
//

#import "CXMapNaviViewSupportable.h"

@interface CXMapNaviWalkView : AMapNaviWalkView<CXMapNaviViewSupportable>

@property (nonatomic, weak) id<CXMapNaviDelegate> naviDelegate;

@end
