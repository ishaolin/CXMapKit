//
//  CXMapPOIAroundSearchOption.h
//  Pods
//
//  Created by lcc on 2018/7/4.
//

#import "CXMapPOISearchBaseOption.h"
#import <AMapSearchKit/AMapSearchKit.h>

@interface CXMapPOIAroundSearchOption : CXMapPOISearchBaseOption

/**
 * 查询关键字，多个关键字用“|”分割
 */
@property (nonatomic, copy) NSString *keywords;

/// 中心点坐标
@property (nonatomic, strong) AMapGeoPoint *location;

/// 查询半径，范围：0-50000，单位：米 [default = 3000]
@property (nonatomic, assign) NSInteger radius;

/// 查询城市，可选值：cityname（中文或中文全拼）、citycode、adcode。注：当用户指定的经纬度和city出现冲突，若范围内有用户指定city的数据，则返回相关数据，否则返回为空。
@property (nonatomic, copy) NSString *city;

@end
