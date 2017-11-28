//
//  POISearch.m
//  RNAMap
//
//  Created by Jason on 2017/11/9.
//  Copyright © 2017年 Jason. All rights reserved.
//

#import "POISearch.h"
#import <AMapFoundationKit/AMapFoundationKit.h>

#import <AMapSearchKit/AMapSearchKit.h>

@interface POISearch()<AMapSearchDelegate>

@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, strong) RCTPromiseResolveBlock resolve;
@property (nonatomic, strong) RCTPromiseRejectBlock reject;

@end

@implementation POISearch

//+ (NSString *)moduleName {
//    return @"POISearch";
//}

RCT_EXPORT_MODULE(POISearch)

//#pragma mark - Lifecycle
- (void) dealloc {
//    self.search = [[AMapSearchAPI alloc] init];
    self.resolve = nil;
    self.reject = nil;
    self.search = nil;
//    self.search.delegate = self;
}

// 根据GPS坐标获取地址
RCT_EXPORT_METHOD(getAddressByLngLat: (NSDictionary *) params) {
    if (self.search == nil) {
        self.search = [[AMapSearchAPI alloc] init];
        self.search.delegate = self;
    }
    AMapReGeocodeSearchRequest *request = [[AMapReGeocodeSearchRequest alloc] init];
    
    if (params != nil) {
        double latitude = [[params objectForKey:@"latitude"] doubleValue];
        double longitude = [[params objectForKey:@"longitude"] doubleValue];
        request.location = [AMapGeoPoint locationWithLatitude:latitude longitude:longitude];
        
        NSArray *keys = [params allKeys];
        if ([keys containsObject:@"requireExtension"]) {
            BOOL requireExtension = [[params objectForKey:@"requireExtension"] boolValue];
            request.requireExtension = requireExtension;
        }
        if([keys containsObject:@"radius"]) {
            // 半径
            int radius = [[params objectForKey:@"radius"] intValue];
            request.radius = radius;
        }
    }
    [self.search AMapReGoecodeSearch:request];
    
}

RCT_EXPORT_METHOD(searchPoiByKeyword: (NSDictionary *) params
                  resolve: (RCTPromiseResolveBlock)resolve
                   reject: (RCTPromiseRejectBlock) reject)
{
    if (self.search == nil) {
        self.search = [[AMapSearchAPI alloc] init];
        self.search.delegate = self;
    }
    self.resolve = resolve;
    self.reject = reject;
    
    AMapPOIKeywordsSearchRequest *request =[[AMapPOIKeywordsSearchRequest alloc] init];
    
    if(params != nil) {
        NSArray *keys = [params allKeys];
        if ([keys containsObject:@"keyword"]) {
            // 关键字
            NSString *keyword = [params objectForKey:@"keyword"];
            request.keywords = keyword;
        }
        if ([keys containsObject:@"types"]) {
            // 类型
            NSString *types = [params objectForKey:@"types"];
            request.types = types;
        }
        if([keys containsObject:@"city"]) {
            // 搜索的城市
            NSString *city = [params objectForKey:@"city"];
            request.city = city;
        }
        if([keys containsObject:@"offset"]) {
            // 偏移量, 每页返回的条数
            int offset = [[params objectForKey:@"offset"] intValue];
            request.offset = offset;
        }
        if([keys containsObject:@"requireExtension"]) {
            
            BOOL requireExtension = [[params objectForKey:@"requireExtension"] boolValue];
            request.requireExtension = requireExtension;
        }
        if([keys containsObject:@"cityLimit"]) {
//            request.cityLimit = false;
            // 搜索的城市
            BOOL cityLimit = [[params objectForKey:@"cityLimit"] boolValue];
            request.cityLimit = cityLimit;
        }
        [self.search AMapPOIKeywordsSearch:request];
    }
}
// 根据坐标获取GPS
RCT_EXPORT_METHOD(searchPoiByCenterCoordinate: (NSDictionary *) params
                  resolve: (RCTPromiseResolveBlock)resolve
                  reject: (RCTPromiseRejectBlock) reject)
{
    if (self.search == nil) {
        self.search = [[AMapSearchAPI alloc] init];
        self.search.delegate = self;
    }
    self.resolve = resolve;
    self.reject = reject;
    AMapPOIAroundSearchRequest * request = [[AMapPOIAroundSearchRequest alloc] init];
    if (params != nil) {
        NSArray *keys = [params allKeys];
        if ([keys containsObject:@"types"]) {
            // 类型
            NSString *types = [params objectForKey:@"types"];
            request.types = types;
        }
        if([keys containsObject:@"sortrule"]) {
            // 排序规则
            int sortrule = [[params objectForKey:@"sortrule"] intValue];
            request.sortrule = sortrule;
        }
        if([keys containsObject:@"offset"]) {
            // 偏移量
            int offset = [[params objectForKey:@"offset"] intValue];
            request.offset = offset;
        }
        if([keys containsObject:@"page"]) {
            // 页码
            int page = [[params objectForKey:@"page"] intValue];
            request.page = page;
        }
        if([keys containsObject:@"requireExtension"]) {
            
            BOOL requireExtension = [[params objectForKey:@"requireExtension"] boolValue];
            request.requireExtension = requireExtension;
        }
        if([keys containsObject:@"requireSubPOIs"]) {
            BOOL requireSubPOIs = [[params objectForKey:@"requireSubPOIs"] boolValue];
            request.requireSubPOIs = requireSubPOIs;
        }
        
        if([keys containsObject:@"keyword"]) {
            NSString *keywords = [params objectForKey:@"keyword "];
            request.keywords = keywords;
        }
        if([keys containsObject:@"coordinate"]) {
            NSDictionary *coordinate = [params objectForKey:@"coordinate"];
            double latitude = [[coordinate objectForKey:@"latitude"] doubleValue];
            double longitude = [[coordinate objectForKey:@"longitude"] doubleValue];
            request.location = [AMapGeoPoint locationWithLatitude:latitude longitude:longitude];
        }
        if([keys containsObject:@"radius"]) {
            // 半径
            int radius = [[params objectForKey:@"radius"] intValue];
            request.radius = radius;
        }
        // 发起搜索
        [self.search AMapPOIAroundSearch:request];
    }
}

#pragma mark - AMapSearchDelegate
/* 搜索失败 */
-(void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSDictionary *result;
    NSString *errorCodeStr = [NSString stringWithFormat:@"%ld", (long)error.code];
    result = @{
               @"code": @(error.code),
               @"message": error.localizedDescription
               };
    
    if (self.reject != nil) {
        self.reject(errorCodeStr, error.localizedDescription, error);
    }
}

-(void) onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    
}

/* 搜索成功 */
-(void) onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    NSDictionary *result;
    NSMutableArray *resultList;
    resultList = [NSMutableArray arrayWithCapacity:response.pois.count];
    
    if (response.pois.count > 0)
    {
        [response.pois enumerateObjectsUsingBlock:^(AMapPOI * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [resultList addObject:@{
                                    @"uid": obj.uid,
                                    @"name": obj.name,
                                    @"type": obj.type,
                                    @"typecode": obj.typecode,
                                    @"latitude": @(obj.location.latitude),
                                    @"longitude": @(obj.location.longitude),
                                    @"address": obj.address,
                                    @"tel": obj.tel,
                                    @"distance": @(obj.distance)
                                    }];
        }];
        
        result = @{
                   @"resultList": resultList,
                   @"status": @"OK"
                   };
//        if (self.resolve != nil) {
//            self.resolve(result);
//        }
    } else {
        result = @{
                   @"resultList": @[],
                   @"status": @"OK"
                   };
//        if (self.resolve != nil) {
//            self.resolve(result);
//        }
    }
    if (self.resolve != nil) {
        self.resolve(result);
    }
    
}

@end