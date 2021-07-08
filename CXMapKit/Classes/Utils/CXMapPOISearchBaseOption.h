//
//  CXMapPOISearchBaseOption.h
//  CXMapKit
//
//  Created by lcc on 2018/6/25.
//


#import "CXMapSearchOption.h"

@interface CXMapPOISearchBaseOption : CXMapSearchOption

/**
 * 类型，多个类型用“|”分割 可选值:文本分类、分类代码
 */
@property (nonatomic, copy)   NSString  *types;

/**
 * 排序规则, 0-距离排序；1-综合排序, 默认0
 */
@property (nonatomic, assign) NSInteger  sortrule;

/**
 * 每页记录数, 范围1-50
 */
@property (nonatomic, assign) NSInteger  offset;

/**
 * 当前页数, 范围1-100
 */
@property (nonatomic, assign) NSInteger  page;

/**
 * 建筑物POI编号，传入建筑物POI之后，则只在该建筑物之内进行搜索
 */
@property (nonatomic, copy) NSString *building;

/**
 * 是否返回扩展信息，默认为 NO
 */
@property (nonatomic, assign) BOOL requireExtension;

/**
 * 是否返回子POI，默认为 NO
 */
@property (nonatomic, assign) BOOL requireSubPOIs;

@end
