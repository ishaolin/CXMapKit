//
//  CXMapPOIKeywordsSearchOption.h
//  Pods
//
//  Created by lcc on 2018/6/25.
//

#import "CXMapPOISearchBaseOption.h"
#import <AMapSearchKit/AMapSearchKit.h>

@interface CXMapPOIKeywordsSearchOption : CXMapPOISearchBaseOption

/**
 * 查询关键字，多个关键字用“|”分割
 */
@property (nonatomic, copy) NSString *keywords;

/**
 * 查询城市，可选值：cityname（中文或中文全拼）、citycode、adcode.（注：台湾地区一律设置为【台湾】，不具体到市）
 */
@property (nonatomic, copy) NSString *city;

/**
 * 强制城市限制功能 默认NO，例如：在上海搜索天安门，如果citylimit为true，将不返回北京的天安门相关的POI
 */
@property (nonatomic, assign) BOOL cityLimit;

/**
 * 设置后，如果sortrule未0，则返回结果会按照距离此点的远近来排序
 */
@property (nonatomic, strong) AMapGeoPoint *location;

@end
