//
//  CXLocationManager.h
//  Pods
//
//  Created by wshaolin on 2017/5/12.
//
//

#import <CoreLocation/CoreLocation.h>
#import "CXLocationReverseGeoCodeResult.h"
#import "CXMapKitDefines.h"

@class CXLocationManager;

@protocol CXLocationManagerDelegate <NSObject>

@optional

/**
 *  当定位发生错误时，会调用代理的此方法。
 *
 *  @param locationManager 定位 CXLocationManager 类。
 *  @param error 返回的错误
 */
- (void)locationManager:(CXLocationManager *)locationManager didFailWithError:(NSError *)error;

/**
 *  定位回调函数
 *  @param locationManager 定位 CXLocationManager 类。
 *  @param location 定位结果。
 */
- (void)locationManager:(CXLocationManager *)locationManager didUpdateLocation:(CLLocation *)location;

/**
 *  设备方向改变时回调函数
 *  @param locationManager 定位 CXLocationManager 类。
 *  @param heading 设备朝向。
 */
- (void)locationManager:(CXLocationManager *)locationManager didUpdateHeading:(CLHeading *)heading;

/**
 * 定位逆地理信息回调
 *
 * @param locationManager 定位 CXLocationManager 类。
 * @param result 逆地理信息
 */
- (void)locationManager:(CXLocationManager *)locationManager didReverseGeoCodeResult:(CXLocationReverseGeoCodeResult *)result;

/**
 *  定位权限状态改变时回调函数
 *
 *  @param locationManager 定位 CXLocationManager 类。
 *  @param status 定位权限状态。
 */
- (void)locationManager:(CXLocationManager *)locationManager didChangeAuthorizationStatus:(CLAuthorizationStatus)status;

@end

@interface CXLocationManager : NSObject

@property (nonatomic, strong, readonly) CLLocation *location;
@property (nonatomic, strong, readonly) CXLocationReverseGeoCodeResult *reverseGeoCodeResult;

@property (nonatomic, assign) CLLocationDistance distanceFilter; // 设定定位的最小更新距离。默认为30.0
@property (nonatomic, assign) CLLocationAccuracy desiredAccuracy; // 设定定位精度。默认为kCLLocationAccuracyBest。
@property (nonatomic, assign, getter = isPausesLocationUpdatesAutomatically) BOOL pausesLocationUpdatesAutomatically; // 指定定位是否会被系统自动暂停。默认为YES。只在iOS 6.0之后起作用。
@property (nonatomic, assign, getter = isAllowsBackgroundLocationUpdates) BOOL allowsBackgroundLocationUpdates; // 指定定位：是否允许后台定位更新。默认为YES。只在iOS 9.0之后起作用。设为YES时，Info.plist中 UIBackgroundModes 必须包含 "location"
@property (nonatomic, assign, getter = isReverseGeoCodeForLocationEnabled) BOOL reverseGeoCodeForLocationEnabled; // 定位是否返回逆地理信息，默认YES。

+ (instancetype)sharedManager;

/**
 * 刷新单次定位信息
 */
- (void)reloadLocation;

/**
 * 开启定位服务
 * 需要在info.plist文件中添加(以下二选一，两个都添加默认使用NSLocationWhenInUseUsageDescription)：
 * NSLocationWhenInUseUsageDescription 允许在前台使用时获取GPS的描述
 * NSLocationAlwaysUsageDescription 允许永远可获取GPS的描述
 */
- (void)startUpdatingLocation;

/**
 * 关闭定位服务
 */
- (void)stopUpdatingLocation;

/**
 *  开始获取设备朝向，如果设备支持方向识别，则会通过代理回调方法
 */
- (void)startUpdatingHeading;

/**
 *  停止获取设备朝向
 */
- (void)stopUpdatingHeading;

/**
 * 主动请求定位授权
 */
- (void)requestAuthorization:(void (^)(CLLocationManager *locationManager))block;

/**
 * 绑定代理对象
 *
 * @param delegate 代理对象
 */
- (void)bind:(id<CXLocationManagerDelegate>)delegate;

/**
 * 解绑代理对象
 *
 * @param delegate 代理对象
 */
- (void)unbind:(id<CXLocationManagerDelegate>)delegate;

@end

CX_MAPKIT_EXTERN BOOL CXLocationCoordinate2DIsValid(CLLocationCoordinate2D coordinate);
