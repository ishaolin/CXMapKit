//
//  CXMapPOIModel.m
//  Pods
//
//  Created by wshaolin on 2017/5/20.
//
//

#import "CXMapPOIModel.h"

@implementation CXMapPOIModel

+ (instancetype)POIModelWithData:(NSData *)data{
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (NSData *)toData{
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}

- (NSString *)fullAddress{
    return [NSString stringWithFormat:@"%@%@", (self.district ?: @""), (self.address ?: @"")];
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeDouble:_coordinate.latitude forKey:@"coordinate.latitude"];
    [aCoder encodeDouble:_coordinate.longitude forKey:@"coordinate.longitude"];
    [aCoder encodeObject:_identifier forKey:@"identifier"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_address forKey:@"address"];
    [aCoder encodeObject:_province forKey:@"province"];
    [aCoder encodeObject:_pcode forKey:@"pcode"];
    [aCoder encodeObject:_city forKey:@"city"];
    [aCoder encodeObject:_citycode forKey:@"citycode"];
    [aCoder encodeObject:_district forKey:@"district"];
    [aCoder encodeObject:_adcode forKey:@"adcode"];
    [aCoder encodeBool:_cache forKey:@"cache"];
    [aCoder encodeObject:_tel forKey:@"tel"];
    [aCoder encodeObject:_typecode forKey:@"typecode"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super init]){
        CLLocationDegrees latitude = [aDecoder decodeDoubleForKey:@"coordinate.latitude"];
        CLLocationDegrees longitude = [aDecoder decodeDoubleForKey:@"coordinate.longitude"];
        _coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        
        _identifier = [aDecoder decodeObjectForKey:@"identifier"];
        _name = [aDecoder decodeObjectForKey:@"name"];
        _address = [aDecoder decodeObjectForKey:@"address"];
        _province = [aDecoder decodeObjectForKey:@"province"];
        _pcode = [aDecoder decodeObjectForKey:@"pcode"];
        _city = [aDecoder decodeObjectForKey:@"city"];
        _citycode = [aDecoder decodeObjectForKey:@"citycode"];
        _district = [aDecoder decodeObjectForKey:@"district"];
        _adcode = [aDecoder decodeObjectForKey:@"adcode"];
        _cache = [aDecoder decodeBoolForKey:@"cache"];
        _tel = [aDecoder decodeObjectForKey:@"tel"];
        _typecode = [aDecoder decodeObjectForKey:@"typecode"];
    }
    
    return self;
}

@end
