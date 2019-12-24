//
//  FPLocationManager.m
//  TZImagePickerController
//
//  Created by fanpeng on 2017/06/03.
//  Copyright © 2017年 fanpeng. All rights reserved.
//  定位管理类

#import "FPLocationManager.h"
@implementation LocationModel
@end
@interface FPLocationManager ()<CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic,strong)NSMutableArray<FPLocationObject*> *observers;
@property (atomic,assign)BOOL locationing;
@end
@implementation FPLocationManager
+ (instancetype)manager{
    static dispatch_once_t onceToken;
    static FPLocationManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[FPLocationManager alloc]init];
    });
    return manager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
        self.observers = [NSMutableArray array];
    }
    return self;
}
- (void)startLocationObserver:(FPLocationObject *)observer{
    if (![self.observers containsObject:observer]){
        @synchronized (self) {[self.observers addObject:observer];}
    }
    if (!self.locationing) {
        self.locationing = YES;
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark - CLLocationManagerDelegate

/// 地理位置发生改变时触发
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [manager stopUpdatingLocation];
    @synchronized (self) {
        [self.observers enumerateObjectsUsingBlock:^(FPLocationObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.successBlock) obj.successBlock(locations);
            if (!obj.geocodeBlock) [self.observers removeObject:obj];
        }];
    }
    if (locations.count) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:[locations firstObject] completionHandler:^(NSArray *array, NSError *error) {
            @synchronized (self) {
                CLPlacemark *firstMark = array.firstObject;
                NSDictionary *addressDict = firstMark.addressDictionary;
                LocationModel *model = [LocationModel new];
                model.City = addressDict[@"City"];
                model.Country = addressDict[@"Country"];
                model.CountryCode = addressDict[@"CountryCode"];
                model.Name = addressDict[@"Name"];
                model.State = addressDict[@"State"];
                model.Street = addressDict[@"Street"];
                model.SubLocality = addressDict[@"SubLocality"];
                model.SubThoroughfare = addressDict[@"SubThoroughfare"];
                model.Thoroughfare = addressDict[@"Thoroughfare"];
                model.latitude = firstMark.location.coordinate.latitude;
                model.longitude = firstMark.location.coordinate.longitude;
                [self.observers enumerateObjectsUsingBlock:^(FPLocationObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (error) {
                        if (obj.failureBlock) obj.failureBlock(error);
                        [self.observers removeObject:obj];
                    }else{
                        if (obj.geocodeBlock) obj.geocodeBlock(array, model);
                        [self.observers removeObject:obj];
                    }
                }];
                self.locationing = NO;
            }
        }];
    }else{
        self.locationing = NO;
    }
}
/// 定位失败回调方法
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    switch([error code]) {
        case kCLErrorDenied: { // 用户禁止了定位权限
        } break;
        default: break;
    }
    @synchronized (self) {
        [self.observers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(FPLocationObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.failureBlock) {
                obj.failureBlock(error);
            }
            [self.observers removeObject:obj];
        }];
    }
    self.locationing = NO;
}
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    @synchronized (self) {
        if (status != kCLAuthorizationStatusNotDetermined) {
            [self.observers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(FPLocationObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.didChangeAuthorizationStatusBlock) {
                    obj.didChangeAuthorizationStatusBlock(status);
                }
                if (!obj.geocodeBlock && !obj.successBlock && !obj.failureBlock) {
                    [self.observers removeObject:obj];
                }
            }];
        }
    }
}
@end
@interface FPLocationObject()
@end
@implementation FPLocationObject
+ (void)startLocationWithSuccessBlock:(void (^)(NSArray<CLLocation *> *locations))successBlock failureBlock:(void (^)(NSError *error))failureBlock geocoderBlock:(void (^)(NSArray *geocoderArray,LocationModel *locationModel))geocoderBlock{
    FPLocationObject *obj = [FPLocationObject new];
    obj.successBlock = successBlock;
    obj.failureBlock = failureBlock;
    obj.geocodeBlock = geocoderBlock;
    [FPLocationManager.manager startLocationObserver:obj];
}
+ (void)startLocationWithGeocoderBlock:(void (^)(NSArray *geocoderArray,LocationModel *locationModel))geocoderBlock failureBlock:(void (^)(NSError *error))failureBlock{
    FPLocationObject *obj = [FPLocationObject new];
    obj.failureBlock = failureBlock;
    obj.geocodeBlock = geocoderBlock;
    [FPLocationManager.manager startLocationObserver:obj];
}
+ (void)startLocationWithDidChangeAuthorizationStatusBlock:(void (^)(CLAuthorizationStatus status))didChangeAuthorizationStatusBlock{
    FPLocationObject *obj = [FPLocationObject new];
    obj.didChangeAuthorizationStatusBlock = didChangeAuthorizationStatusBlock;
    [FPLocationManager.manager startLocationObserver:obj];
}
@end
