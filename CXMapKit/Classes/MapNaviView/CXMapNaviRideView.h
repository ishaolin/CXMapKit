//
//  CXMapNaviRideView.h
//  CXMapKit
//
//  Created by lcc on 2018/6/19.
//

#import "CXMapNaviViewSupportable.h"

@interface CXMapNaviRideView : AMapNaviRideView<CXMapNaviViewSupportable>

@property (nonatomic, weak) id<CXMapNaviDelegate> naviDelegate;

@end
