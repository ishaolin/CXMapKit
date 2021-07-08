//
//  CXLocationReverseGeoCodeResult.m
//  Pods
//
//  Created by wshaolin on 2017/5/14.
//
//

#import "CXLocationReverseGeoCodeResult.h"

@implementation CXLocationReverseGeoCodeResult

- (CXMapPOIModel *)toMapPOIModel{
    CXMapPOIModel *mapPOIModel = [[CXMapPOIModel alloc] init];
    mapPOIModel.coordinate = self.coordinate;
    mapPOIModel.name = self.POIName;
    mapPOIModel.address = self.formattedAddress;
    mapPOIModel.province = self.province;
    mapPOIModel.city = self.city;
    mapPOIModel.citycode = self.citycode;
    mapPOIModel.district = self.district;
    mapPOIModel.adcode = self.adcode;
    mapPOIModel.identifier = @"0";
    return mapPOIModel;
}

@end
