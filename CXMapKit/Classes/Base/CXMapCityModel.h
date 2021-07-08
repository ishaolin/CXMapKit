//
//  CXMapCityModel.h
//  Pods
//
//  Created by wshaolin on 2017/5/20.
//
//

#import <CoreLocation/CoreLocation.h>

@interface CXMapCityModel : NSObject

@property (nonatomic, copy) NSString  *name; // 城市名称
@property (nonatomic, copy) NSString  *code; // 城市编码
@property (nonatomic, copy) NSString  *adcode; // 城市行政区域编码
@property (nonatomic, assign) CLLocationCoordinate2D centerCoordinate; // 中心点经纬度

@property (nonatomic, strong) NSArray<CXMapCityModel *> *cities; // 下级城市

@end
