//
//  CXMapPOIModel.h
//  Pods
//
//  Created by wshaolin on 2017/5/20.
//
//

#import <CoreLocation/CoreLocation.h>

@interface CXMapPOIModel : NSObject<NSCoding>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate; // 经纬度
@property (nonatomic, copy) NSString *identifier; // POI全局唯一id
@property (nonatomic, copy) NSString *name; // 名称
@property (nonatomic, copy) NSString *address; // 地址
@property (nonatomic, copy) NSString *province; // 省/直辖市
@property (nonatomic, copy) NSString *pcode; // 省编码
@property (nonatomic, copy) NSString *city; // 城市名称
@property (nonatomic, copy) NSString *citycode; // 城市编码
@property (nonatomic, copy) NSString *district; // 区域名称
@property (nonatomic, copy) NSString *adcode; // 区域编码
@property (nonatomic, copy) NSString *tel;    // 电话
@property (nonatomic, copy) NSString *typecode; //种类主要判断是否加油站

@property (nonatomic, assign, getter = isCache) BOOL cache;

+ (instancetype)POIModelWithData:(NSData *)data;

- (NSData *)toData;

- (NSString *)fullAddress;

@end
