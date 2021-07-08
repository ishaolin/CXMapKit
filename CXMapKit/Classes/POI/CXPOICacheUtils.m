//
//  CXPOICacheUtils.m
//  Pods
//
//  Created by wshaolin on 2019/4/14.
//

#import "CXPOICacheUtils.h"
#import <CXMapKit/CXMapPOIModel.h>
#import <CXDatabaseSDK/CXDatabaseSDK.h>
#import <CXFoundation/CXFoundation.h>

static NSString *cacheDataOwnerId = nil;

@implementation CXPOICacheUtils

+ (void)load{
    NSString *tableName = @"T_POIS";
    [CXDatabaseUtils checkTable:tableName column:@"OWNER" existsBlock:^(BOOL tableExists, BOOL columnExists) {
        NSString *sql = @"CREATE TABLE IF NOT EXISTS T_POIS ([NAME] VARCHAR(255) NOT NULL, [CONTENT] BLOB NOT NULL, PID VARCHAR(255) NOT NULL, TYPE INT NOT NULL, DATE DOUBLE NOT NULL, OWNER VARCHAR(255) NOT NULL);";
        if(!tableExists){
            CX_CREATE_TABLE(sql);
            return;
        }
        
        if(!columnExists){
            CX_DROP_TABLE(tableName);
            CX_CREATE_TABLE(sql);
        }
    }];
}

+ (void)setDataOwnerId:(NSString *)dataOwnerId{
    cacheDataOwnerId = dataOwnerId;
}

+ (NSString *)dataOwnerId{
    return CXStringIsEmpty(cacheDataOwnerId) ? @"" : cacheDataOwnerId;
}

+ (void)setPOIModel:(CXMapPOIModel *)POIModel forType:(NSInteger)type{
    if(!POIModel || !POIModel.name){
        return;
    }
    
    [CXDatabaseUtils executeUpdate:@"DELETE FROM T_POIS WHERE NAME = ? AND TYPE = ? AND OWNER = ?;" arguments:@[POIModel.name, @(type), self.dataOwnerId] handler:nil];
    
    [CXDatabaseUtils executeUpdate:@"INSERT INTO T_POIS(CONTENT, PID, NAME, DATE, TYPE, OWNER) VALUES(?, ?, ?, ?, ?, ?);" arguments:@[[POIModel toData], POIModel.identifier ?: @"", POIModel.name, @([NSDate date].timeIntervalSince1970), @(type), self.dataOwnerId] handler:nil];
}

+ (NSArray<CXMapPOIModel *> *)POIModelsForType:(NSInteger)type{
    NSMutableArray<CXMapPOIModel *> *POIModels = [NSMutableArray array];
    [CXDatabaseUtils executeQuery:@"SELECT CONTENT FROM T_POIS WHERE TYPE = ? AND OWNER = ? ORDER BY DATE DESC LIMIT 10 OFFSET 0;" arguments:@[@(type), self.dataOwnerId] handler:^(FMResultSet *rs) {
        while([rs next]){
            NSData *data = [rs dataForColumn:@"CONTENT"];
            CXMapPOIModel *POIModel = [CXMapPOIModel POIModelWithData:data];
            POIModel.cache = YES;
            if(POIModel){
                [POIModels addObject:POIModel];
            }
        }
    }];
    
    return [POIModels copy];
}

+ (void)removeAllPOIModels{
    CX_EMPTY_TABLE(@"T_POIS");
}

@end
