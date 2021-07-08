//
//  CXPOICacheUtils.h
//  Pods
//
//  Created by wshaolin on 2019/4/14.
//

#import <Foundation/Foundation.h>

@class CXMapPOIModel;

@interface CXPOICacheUtils : NSObject

@property (nonatomic, class) NSString *dataOwnerId;

+ (void)setPOIModel:(CXMapPOIModel *)POIModel forType:(NSInteger)type;

+ (NSArray<CXMapPOIModel *> *)POIModelsForType:(NSInteger)type;

+ (void)removeAllPOIModels;

@end
