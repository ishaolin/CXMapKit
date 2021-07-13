//
//  CXMapSearcher.m
//  Pods
//
//  Created by wshaolin on 2017/5/20.
//
//

#import "CXMapSearcher.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import <objc/runtime.h>
#import "CXLocationManager.h"
#import <CXFoundation/CXFoundation.h>
#import <AMapNaviKit/AMapNaviHeaderHandler.h>

@interface AMapSearchObject (CXMapKit)

@property (nonatomic, assign) NSUInteger count;

@end

@implementation AMapSearchObject (CXMapKit)

- (void)setCount:(NSUInteger)count{
    objc_setAssociatedObject(self, @selector(count), @(count), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger)count{
    return [objc_getAssociatedObject(self, _cmd) unsignedIntegerValue];
}

@end

@interface CXMapSearcher() <AMapSearchDelegate> {
    AMapSearchAPI *_searcher;
}

@property (nonatomic, copy) CXSearchPOICompletionHandler POICompletionHandler;
@property (nonatomic, copy) CXSearchCityCompletionHandler cityCompletionHandler;
@property (nonatomic, copy) CXSearchReverseGeoCodeCompletionHandler reverseGeoCodeCompletionHandler;
@property (nonatomic, copy) CXSearchMapDistanceCompletionHandler distanceCompletionHandler;

@end

@implementation CXMapSearcher

+ (instancetype)sharedSearcher{
    static CXMapSearcher *_mapSearcher = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _mapSearcher = [[self alloc] init];
    });
    
    return _mapSearcher;
}

- (instancetype)init{
    if(self = [super init]){
        _searcher = [[AMapSearchAPI alloc] init];
        _searcher.delegate = self;
    }
    
    return self;
}

#pragma mark - 搜索提示请求

+ (void)inputTipsSearch:(CXMapInputTipsSearchOption *)option completionHandler:(CXSearchPOICompletionHandler)completionHandler{
    if(!completionHandler){
        return;
    }
    
    if(CXStringIsEmpty(option.keywords)){
        completionHandler(nil, nil);
        return;
    }
    
    [[self sharedSearcher] _inputTipsSearch:option completionHandler:completionHandler];
}

- (void)_inputTipsSearch:(CXMapInputTipsSearchOption *)option completionHandler:(CXSearchPOICompletionHandler)completionHandler{
    [_searcher cancelAllRequests];
    self.POICompletionHandler = completionHandler;
    AMapInputTipsSearchRequest *request = [[AMapInputTipsSearchRequest alloc] init];
    request.types = option.types;
    request.keywords = option.keywords;
    request.city = option.city;
    request.cityLimit = option.cityLimit;
    request.location =  option.location;
    request.count = option.count;
    [_searcher AMapInputTipsSearch:request];
}

- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response{
    NSMutableArray<CXMapPOIModel *> *POIs = [NSMutableArray array];
    [response.tips enumerateObjectsUsingBlock:^(AMapTip * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(!obj.location){
            return;
        }
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(obj.location.latitude, obj.location.longitude);
        if(!CXLocationCoordinate2DIsValid(coordinate)){
            return;
        }
        
        CXMapPOIModel *POIModel = [[CXMapPOIModel alloc] init];
        POIModel.coordinate = coordinate;
        POIModel.identifier = obj.uid;
        POIModel.name = obj.name;
        POIModel.address = obj.address;
        POIModel.district = obj.district;
        POIModel.adcode = obj.adcode;
        POIModel.cache = NO;
        POIModel.typecode = obj.typecode;
        [POIs addObject:POIModel];
        
        if(POIs.count >= request.count){
            *stop = YES;
        }
    }];
    
    [self didCompletedSearchPOI:[POIs copy] error:nil];
}

#pragma mark - POI关键字搜索

+ (void)POIMapPOIKeywordsSearch:(CXMapPOIKeywordsSearchOption *)option completionHandler:(CXSearchPOICompletionHandler)completionHandler{
    if(!completionHandler){
        return;
    }
    
    if(CXStringIsEmpty(option.keywords)){
        completionHandler(nil, nil);
        return;
    }
    
    [[self sharedSearcher] _POIMapPOIKeywordsSearch:option completionHandler:completionHandler];
}

- (void)_POIMapPOIKeywordsSearch:(CXMapPOIKeywordsSearchOption *)option completionHandler:(CXSearchPOICompletionHandler)completionHandler{
    [_searcher cancelAllRequests];
    self.POICompletionHandler = completionHandler;
    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
    request.keywords = option.keywords;
    request.cityLimit = option.cityLimit;
    request.city = option.city;
    request.location = option.location;
    request.sortrule = option.sortrule;
    request.offset = option.offset;
    request.page = option.page;
    request.count = option.count;
    request.types = option.types;
    [_searcher AMapPOIKeywordsSearch:request];
}

#pragma mark - 搜周边

+ (void)POIMapAroundSearch:(CXMapPOIAroundSearchOption *)option completionHandler:(CXSearchPOICompletionHandler)completionHandler{
    if(!completionHandler){
        return;
    }
    
    if(CXStringIsEmpty(option.keywords)){
        completionHandler(nil, nil);
        return;
    }
    
    [[self sharedSearcher] _POIMapAroundSearch:option completionHandler:completionHandler];
}

- (void)_POIMapAroundSearch:(CXMapPOIAroundSearchOption *)option completionHandler:(CXSearchPOICompletionHandler)completionHandler{
    [_searcher cancelAllRequests];
    self.POICompletionHandler = completionHandler;
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.keywords = option.keywords;
    request.city = option.city;
    request.radius = option.radius;
    request.location = option.location;
    request.page = option.page;
    request.types = option.types;
    request.count = option.count;
    request.offset = option.offset;
    [_searcher AMapPOIAroundSearch:request];
}

- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    NSMutableArray<CXMapPOIModel *> *POIs = [NSMutableArray array];
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
        if(!obj.location){
            return;
        }
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(obj.location.latitude, obj.location.longitude);
        if(!CXLocationCoordinate2DIsValid(coordinate)){
            return;
        }
        
        CXMapPOIModel *POIModel = [[CXMapPOIModel alloc] init];
        POIModel.coordinate = CLLocationCoordinate2DMake(obj.location.latitude, obj.location.longitude);
        POIModel.identifier = obj.uid;
        POIModel.name = obj.name;
        POIModel.address = obj.address;
        POIModel.province = obj.province;
        POIModel.pcode = obj.pcode;
        POIModel.city = obj.city;
        POIModel.citycode = obj.citycode;
        POIModel.district = obj.district;
        POIModel.adcode = obj.adcode;
        POIModel.tel = obj.tel;
        POIModel.cache = NO;
        POIModel.typecode = obj.typecode;
        [POIs addObject:POIModel];
        
        if(POIs.count >= request.count){
            *stop = YES;
        }
    }];
    
    [self didCompletedSearchPOI:[POIs copy] error:nil];
}

#pragma mark - 行政区划查询请求

+ (void)citySearch:(CXCitySearchOption *)option completionHandler:(CXSearchCityCompletionHandler)completionHandler{
    if(!completionHandler){
        return;
    }
    
    if(CXStringIsEmpty(option.keywords)){
        completionHandler(nil);
        return;
    }
    
    [[self sharedSearcher] _citySearch:option completionHandler:completionHandler];
}

- (void)_citySearch:(CXCitySearchOption *)option completionHandler:(CXSearchCityCompletionHandler)completionHandler{
    self.cityCompletionHandler = completionHandler;
    
    AMapDistrictSearchRequest *request = [[AMapDistrictSearchRequest alloc] init];
    request.keywords = option.keywords;
    [_searcher AMapDistrictSearch:request];
}

- (void)onDistrictSearchDone:(AMapDistrictSearchRequest *)request response:(AMapDistrictSearchResponse *)response{
    NSMutableArray<CXMapCityModel *> *cities = [NSMutableArray array];
    [response.districts enumerateObjectsUsingBlock:^(AMapDistrict *obj, NSUInteger idx, BOOL *stop) {
        CXMapCityModel *cityModel = [[CXMapCityModel alloc] init];
        cityModel.adcode = obj.adcode;
        cityModel.name = obj.name;
        cityModel.code = obj.citycode;
        cityModel.centerCoordinate = CLLocationCoordinate2DMake(obj.center.latitude, obj.center.longitude);
        
        // 下级城市
        NSMutableArray<CXMapCityModel *> *_cities = [NSMutableArray array];
        [obj.districts enumerateObjectsUsingBlock:^(AMapDistrict *_obj, NSUInteger _idx, BOOL *_stop) {
            CXMapCityModel *_cityModel = [[CXMapCityModel alloc] init];
            _cityModel.adcode = _obj.adcode;
            _cityModel.name = _obj.name;
            _cityModel.code = _obj.citycode;
            _cityModel.centerCoordinate = CLLocationCoordinate2DMake(_obj.center.latitude, _obj.center.longitude);
            [_cities addObject:_cityModel];
        }];
        
        cityModel.cities = [_cities copy];
        [cities addObject:cityModel];
    }];
    
    [self didCompletedSearchCity:[cities copy]];
}

#pragma mark - 逆地理编码请求

+ (void)reverseGeoCodeSearch:(CLLocationCoordinate2D)coordinate completionHandler:(CXSearchReverseGeoCodeCompletionHandler)completionHandler{
    if(!completionHandler){
        return;
    }
    
    if(!CXLocationCoordinate2DIsValid(coordinate)){
        completionHandler(nil);
        return;
    }
    
    [[self sharedSearcher] _reverseGeoCodeSearch:coordinate completionHandler:completionHandler];
}

- (void)_reverseGeoCodeSearch:(CLLocationCoordinate2D)coordinate completionHandler:(CXSearchReverseGeoCodeCompletionHandler)completionHandler{
    self.reverseGeoCodeCompletionHandler = completionHandler;
    AMapReGeocodeSearchRequest *request = [[AMapReGeocodeSearchRequest alloc] init];
    request.requireExtension = YES;
    request.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    request.radius = 100;
    [_searcher AMapReGoecodeSearch:request];
}

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
    CXMapPOIModel *POIModel = nil;
    __block AMapPOI *MapPOI = nil;
    __block NSInteger minDistance = 0;
    [response.regeocode.pois enumerateObjectsUsingBlock:^(AMapPOI * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(idx == 0){
            minDistance = obj.distance;
            MapPOI = obj;
        }else if(obj.distance < minDistance){
            minDistance = obj.distance;
            MapPOI = obj;
        }
    }];
    
    if(MapPOI){
        POIModel = [[CXMapPOIModel alloc] init];
        POIModel.coordinate = CLLocationCoordinate2DMake(MapPOI.location.latitude, MapPOI.location.longitude);
        POIModel.identifier = MapPOI.uid;
        POIModel.name = MapPOI.name;
        POIModel.address = MapPOI.address;
        
        POIModel.province = !CXStringIsEmpty(MapPOI.province) ? MapPOI.province : response.regeocode.addressComponent.province;
        POIModel.pcode = MapPOI.pcode;
        
        POIModel.city = !CXStringIsEmpty(MapPOI.city) ? MapPOI.city : response.regeocode.addressComponent.city;
        POIModel.citycode = !CXStringIsEmpty(MapPOI.citycode) ? MapPOI.citycode : response.regeocode.addressComponent.citycode;
        
        POIModel.district = !CXStringIsEmpty(MapPOI.district) ? MapPOI.district : response.regeocode.addressComponent.district;
        POIModel.adcode = !CXStringIsEmpty(MapPOI.adcode) ? MapPOI.adcode : response.regeocode.addressComponent.adcode;
        
        POIModel.cache = NO;
        POIModel.tel = MapPOI.tel;
        POIModel.typecode = MapPOI.typecode;
    }
    
    [self didCompletedSearchReverseGeoCode:POIModel];
}

+ (void)calculateDistanceForCoordinates:(NSArray<NSValue *> *)coordinates
                          endCoordinate:(CLLocationCoordinate2D)endCoordinate
                      completionHandler:(CXSearchMapDistanceCompletionHandler)completionHandler{
    if(!completionHandler){
        return;
    }
    
    if(CXArrayIsEmpty(coordinates) || !CXLocationCoordinate2DIsValid(endCoordinate)){
        completionHandler(nil);
        return;
    }
    
    [[self sharedSearcher] calculateDistanceForCoordinates:coordinates
                                             endCoordinate:endCoordinate
                                         completionHandler:completionHandler];
}

- (void)calculateDistanceForCoordinates:(NSArray<NSValue *> *)coordinates
                          endCoordinate:(CLLocationCoordinate2D)endCoordinate
                      completionHandler:(CXSearchMapDistanceCompletionHandler)completionHandler{
    self.distanceCompletionHandler = completionHandler;
    NSMutableArray<AMapGeoPoint *> *points = [NSMutableArray array];
    [coordinates enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CLLocationCoordinate2D coordinate = [obj MACoordinateValue];
        AMapGeoPoint *point = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        [points addObject:point];
    }];
    
    AMapGeoPoint *endPoint = [AMapGeoPoint locationWithLatitude:endCoordinate.latitude longitude:endCoordinate.longitude];
    AMapDistanceSearchRequest *request = [[AMapDistanceSearchRequest alloc] init];
    request.origins = [points copy];
    request.destination = endPoint;
    request.type = 1;
    [_searcher AMapDistanceSearch:request];
}

- (void)onDistanceSearchDone:(AMapDistanceSearchRequest *)request response:(AMapDistanceSearchResponse *)response{
    NSMutableArray<CXMapDistanceModel *> *models = [NSMutableArray array];
    [response.results enumerateObjectsUsingBlock:^(AMapDistanceResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CXMapDistanceModel *model = [[CXMapDistanceModel alloc] init];
        model.distance = obj.distance;
        model.duration = obj.duration;
        model.error = obj.info;
        [models addObject:model];
    }];
    
    [self didCompletedSearchMapDistance:[models copy]];
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error{
    if(error.code == 1807){ // 取消请求
        return;
    }
    
    if([request isKindOfClass:[AMapPOIKeywordsSearchRequest class]]){
        [self didCompletedSearchPOI:nil error:error];
    }else if([request isKindOfClass:[AMapDistrictSearchRequest class]]){
        [self didCompletedSearchCity:nil];
    }else if([request isKindOfClass:[AMapReGeocodeSearchRequest class]]){
        [self didCompletedSearchReverseGeoCode:nil];
    }else if([request isKindOfClass:[AMapDistanceSearchRequest class]]){
        [self didCompletedSearchMapDistance:nil];
    }
}

- (void)didCompletedSearchPOI:(NSArray<CXMapPOIModel *> *)POIs error:(NSError *)error{
    if(self.POICompletionHandler){
        self.POICompletionHandler(POIs, error);
        self.POICompletionHandler = NULL;
    }
}

- (void)didCompletedSearchCity:(NSArray<CXMapCityModel *> *)cities{
    if(self.cityCompletionHandler){
        self.cityCompletionHandler(cities);
        self.cityCompletionHandler = NULL;
    }
}

- (void)didCompletedSearchReverseGeoCode:(CXMapPOIModel *)POIModel{
    if(self.reverseGeoCodeCompletionHandler){
        self.reverseGeoCodeCompletionHandler(POIModel);
        self.reverseGeoCodeCompletionHandler = NULL;
    }
}

- (void)didCompletedSearchMapDistance:(NSArray<CXMapDistanceModel *> *)models{
    if(self.distanceCompletionHandler){
        self.distanceCompletionHandler(models);
        self.distanceCompletionHandler = NULL;
    }
}

@end
