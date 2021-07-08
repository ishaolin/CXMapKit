//
//  CXMapRouteRequestOption.h
//  Pods
//
//  Created by wshaolin on 2018/4/27.
//

#import "CXMapPOIModel.h"
#import "CXMapKitDefines.h"

@class CXMapRoutePreference, CXPointAnnotation;

typedef CXPointAnnotation *(^CXMapRouteAnnotationBlock)(CLLocationCoordinate2D coordinate);

@interface CXMapRouteRequestOption : NSObject

@property (nonatomic, assign, readonly) CLLocationCoordinate2D startCoordinate;
@property (nonatomic, assign, readonly) CLLocationCoordinate2D endCoordinate;
@property (nonatomic, copy, readonly) NSString *originId;
@property (nonatomic, copy, readonly) NSString *destinationId;

@property (nonatomic, copy) CXMapRouteAnnotationBlock startAnnotationBlock;
@property (nonatomic, copy) CXMapRouteAnnotationBlock endAnnotationBlock;
@property (nonatomic, assign) CXMapNaviType naviType;
@property (nonatomic, assign, readonly) NSInteger strategy;
@property (nonatomic, assign, getter = isShowTraffic) BOOL showTraffic; // 是否显示路况

- (instancetype)initWithStartCoordinate:(CLLocationCoordinate2D)startCoordinate
                          endCoordinate:(CLLocationCoordinate2D)endCoordinate
                               naviType:(CXMapNaviType)naviType
                             preference:(CXMapRoutePreference *)preference;

- (instancetype)initWithStartPOIModel:(CXMapPOIModel *)startPOIModel
                          endPOIModel:(CXMapPOIModel *)endPOIModel
                             naviType:(CXMapNaviType)naviType
                           preference:(CXMapRoutePreference *)preference;

@end

@interface CXMapRoutePreference : NSObject

@property (nonatomic, assign) BOOL avoidCongestion; // 躲避拥堵
@property (nonatomic, assign) BOOL avoidCost; // 避免收费
@property (nonatomic, assign) BOOL avoidHighway; // 不走高速
@property (nonatomic, assign) BOOL prioritiseHighway; // 高速优先

- (BOOL)isEqualToPreference:(CXMapRoutePreference *)preference;
- (CXMapRoutePreference *)copyPreference;

@end
