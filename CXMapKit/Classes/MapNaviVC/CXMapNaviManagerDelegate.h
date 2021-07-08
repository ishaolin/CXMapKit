//
//  CXMapNaviManagerDelegate.h
//  Pods
//
//  Created by wshaolin on 2019/4/12.
//

#import <AMapNaviKit/AMapNaviKit.h>
#import "CXMapKitDefines.h"

@protocol CXMapNaviManagerDelegate <NSObject>

@optional

- (void)naviManager:(AMapNaviBaseManager *)manager naviType:(CXMapNaviType)naviType error:(NSError *)error;
- (void)naviManagerOnCalculateRouteSuccess:(AMapNaviBaseManager *)manager naviType:(CXMapNaviType)naviType;
- (void)naviManager:(AMapNaviBaseManager *)manager naviType:(CXMapNaviType)naviType onCalculateRouteFailure:(NSError *)error;
- (void)naviManager:(AMapNaviBaseManager *)manager naviType:(CXMapNaviType)naviType didStartNavi:(AMapNaviMode)mode;
- (void)naviManagerOnArrivedDestination:(AMapNaviBaseManager *)manager naviType:(CXMapNaviType)naviType;
- (void)naviManager:(AMapNaviBaseManager *)manager naviType:(CXMapNaviType)naviType updateNaviInfo:(AMapNaviInfo *)naviInfo;
- (void)naviManager:(AMapNaviBaseManager *)manager naviType:(CXMapNaviType)naviType updateNaviLocation:(AMapNaviLocation *)naviLocation;

- (void)driveManager:(AMapNaviDriveManager *)manager showCrossImage:(UIImage *)crossImage;
- (void)driveManagerHideCrossImage:(AMapNaviDriveManager *)manager;
- (void)driveManager:(AMapNaviDriveManager *)manager showLaneInfoImage:(UIImage *)image;
- (void)driveManagerHideLaneInfo:(AMapNaviDriveManager *)manager;

@end
