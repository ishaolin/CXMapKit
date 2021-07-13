//
//  AMapNaviRoute+CXMapKit.h
//  Pods
//
//  Created by lcc on 2018/5/17.
//

#import <AMapNaviKit/AMapNaviKit.h>
#import "CXMapRouteRequestOption.h"

@interface AMapNaviRoute (CXMapKit)

@property (nonatomic, strong) CXMapRouteRequestOption *requestOption;
@property (nonatomic, strong) NSNumber *routeId;
@property (nonatomic, assign, getter = isSelected) BOOL selected;

@end
