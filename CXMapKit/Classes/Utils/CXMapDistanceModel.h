//
//  CXMapDistanceModel.h
//  Pods
//
//  Created by wshaolin on 2019/3/1.
//

#import <Foundation/Foundation.h>

@interface CXMapDistanceModel : NSObject

@property (nonatomic, assign) NSInteger distance; // 路径距离，单位：米
@property (nonatomic, assign) NSInteger duration; // 预计行驶时间，单位：秒
@property (nonatomic, copy) NSString *error; // 失败信息

@end
