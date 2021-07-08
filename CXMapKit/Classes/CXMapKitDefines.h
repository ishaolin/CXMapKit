//
//  CXMapKitDefines.h
//  Pods
//
//  Created by wshaolin on 2019/4/14.
//

#ifndef CXMapKitDefines_h
#define CXMapKitDefines_h

#import <CXUIKit/CXUIKit.h>

#if defined(__cplusplus)
#define CX_MAPKIT_EXTERN   extern "C"
#else
#define CX_MAPKIT_EXTERN   extern
#endif

#define CX_MAPKIT_IMAGE(name) CX_POD_IMAGE(name, @"CXMapKit")

typedef NS_ENUM(NSUInteger, CXMapNaviType){ // 导航类型
    CXMapNaviDrive  = 0,  // 驾车
    CXMapNaviRide   = 1,  // 骑行
    CXMapNaviWalk   = 2   // 步行
};

typedef NS_ENUM(NSInteger, CXMapNaviTrackingType){ // 导航模式
    CXMapNaviTracking2D    = 0,  // 2D模式
    CXMapNaviTracking3D    = 1,  // 3D模式
    CXMapNaviTrackingNorth = 2   // 地图朝北模式
};

typedef NS_ENUM(NSInteger, CXMapNaviShowMode){
    CXMapNaviShowModeCarPositionLocked  = 1,  // 锁车状态
    CXMapNaviShowModeOverview           = 2,  // 全览状态
    CXMapNaviShowModeNormal             = 3   // 普通状态
};

#endif /* CXMapKitDefines_h */
