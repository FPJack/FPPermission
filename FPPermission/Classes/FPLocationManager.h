//
//  FPLocationManager.h
//  TZImagePickerController
//
//  Created by fanpeng on 2017/06/03.
//  Copyright © 2017年 fanpeng. All rights reserved.
//  定位管理类


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@class FPLocationObject;
@interface LocationModel : NSObject
@property (nonatomic,copy)NSString *City;
@property (nonatomic,copy)NSString *Country;
@property (nonatomic,copy)NSString *CountryCode;
@property (nonatomic,copy)NSString *Name;
@property (nonatomic,copy)NSString *State;
@property (nonatomic,copy)NSString *Street;
@property (nonatomic,copy)NSString *SubLocality;
@property (nonatomic,copy)NSString *SubThoroughfare;
@property (nonatomic,copy)NSString *Thoroughfare;
@property (nonatomic,assign)CGFloat latitude;
@property (nonatomic,assign)CGFloat longitude;
@end
@interface FPLocationManager : NSObject
+ (instancetype)manager;
/// 开始定位
- (void)startLocationObserver:(FPLocationObject *)observer;

@end

@interface FPLocationObject : NSObject
/// 定位成功的回调block
@property (nonatomic, copy) void (^successBlock)(NSArray<CLLocation *> *);
/// 编码成功的回调block
@property (nonatomic, copy) void (^geocodeBlock)(NSArray *geocodeArray,LocationModel *locationModel);
/// 定位失败的回调block
@property (nonatomic, copy) void (^failureBlock)(NSError *error);
/// 权限改变的回调block
@property (nonatomic, copy) void (^didChangeAuthorizationStatusBlock)(CLAuthorizationStatus status);
+ (void)startLocationWithSuccessBlock:(void (^)(NSArray<CLLocation *> *locations))successBlock failureBlock:(void (^)(NSError *error))failureBlock geocoderBlock:(void (^)(NSArray *geocoderArray,LocationModel *locationModel))geocoderBlock;
+ (void)startLocationWithGeocoderBlock:(void (^)(NSArray *geocoderArray,LocationModel *locationModel))geocoderBlock failureBlock:(void (^)(NSError *error))failureBlock;
+ (void)startLocationWithDidChangeAuthorizationStatusBlock:(void (^)(CLAuthorizationStatus status))didChangeAuthorizationStatusBlock;
@end
