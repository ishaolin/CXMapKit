//
//  CXMapSearcher.h
//  Pods
//
//  Created by wshaolin on 2017/5/20.
//
//

#import "CXCitySearchOption.h"
#import "CXMapInputTipsSearchOption.h"
#import "CXMapPOIKeywordsSearchOption.h"
#import "CXMapPOIAroundSearchOption.h"
#import "CXMapPOIModel.h"
#import "CXMapCityModel.h"
#import "CXMapDistanceModel.h"

typedef void (^CXSearchPOICompletionHandler)(NSArray<CXMapPOIModel *> *POIs, NSError *error);
typedef void (^CXSearchCityCompletionHandler)(NSArray<CXMapCityModel *> *cities);
typedef void (^CXSearchReverseGeoCodeCompletionHandler)(CXMapPOIModel *POIModel);
typedef void (^CXSearchMapDistanceCompletionHandler)(NSArray<CXMapDistanceModel *> *models);

@interface CXMapSearcher : NSObject

+ (void)inputTipsSearch:(CXMapInputTipsSearchOption *)option completionHandler:(CXSearchPOICompletionHandler)completionHandler;

+ (void)POIMapPOIKeywordsSearch:(CXMapPOIKeywordsSearchOption *)option completionHandler:(CXSearchPOICompletionHandler)completionHandler;

+ (void)POIMapAroundSearch:(CXMapPOIAroundSearchOption *)option completionHandler:(CXSearchPOICompletionHandler)completionHandler;

+ (void)citySearch:(CXCitySearchOption *)option completionHandler:(CXSearchCityCompletionHandler)completionHandler;

+ (void)reverseGeoCodeSearch:(CLLocationCoordinate2D)coordinate completionHandler:(CXSearchReverseGeoCodeCompletionHandler)completionHandler;

+ (void)calculateDistanceForCoordinates:(NSArray<NSValue *> *)coordinates
                          endCoordinate:(CLLocationCoordinate2D)endCoordinate
                      completionHandler:(CXSearchMapDistanceCompletionHandler)completionHandler;

@end
