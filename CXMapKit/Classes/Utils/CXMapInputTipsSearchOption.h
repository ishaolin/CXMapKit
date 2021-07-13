//
//  CXMapInputTipsSearchOption.h
//  Pods
//
//  Created by lcc on 2018/6/25.
//

#import "CXMapSearchOption.h"

@interface CXMapInputTipsSearchOption : CXMapSearchOption

/**
 * 类型，多个类型用“|”分割 可选值:文本分类、分类代码
 */
@property (nonatomic, copy) NSString *types;

/**
 * 查询关键字，多个关键字用“|”分割
 */
@property (nonatomic, copy) NSString *keywords;

/**
 * 查询城市，可选值：cityname（中文或中文全拼）、citycode、adcode（注：台湾地区一律设置为【台湾】，不具体到市）
 */
@property (nonatomic, copy) NSString *city;

/**
 * 强制城市限制功能，例如：在上海搜索天安门，如果citylimit为YES，将不返回北京的天安门相关的POI
 */
@property (nonatomic, assign) BOOL cityLimit;

/**
 * 格式形如：@"116.481488,39.990464"，(经度,纬度)，不可以包含空格。如果设置，在此location附近优先返回搜索关键词信息
 */
@property (nonatomic, copy) NSString *location;

@end
