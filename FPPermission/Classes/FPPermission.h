//
//  Permission.h
//  ZhiChongRadar
//
//  Created by fanpeng on 2019/10/24.
//  Copyright © 2019 zhichongjia. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, FPPermissionType) {
    FPPermissionCamer = 0,
    FPPermissionPhoto,
    FPPermissionLocation,
    FPPermissionBluetooth
};
typedef NS_ENUM(NSInteger, FPPermissionStatus) {
    FPPermissionStatusNotDetermined = 0,
    FPPermissionStatusDenied,
    FPPermissionStatusAuthorized,
    FPPermissionStatusRestricted,
    FPPermissionStatusAuthorizedWhenUse,//定位特定多一个返回状态
    FPPermissionStatusPoweredOff
};
#define kPermissionTitleInfo @{@(FPPermissionCamer):@"相机",\
                               @(FPPermissionPhoto):@"相册",\
                                @(FPPermissionLocation):@"定位",\
                                @(FPPermissionBluetooth):@"蓝牙"}
#define kPermissionDesInfo @{@(FPPermissionCamer):@"NSCameraUsageDescription",\
                             @(FPPermissionPhoto):@"NSPhotoLibraryUsageDescription",\
                            @(FPPermissionLocation):@"NSLocationWhenInUseUsageDescription",\
                            @(FPPermissionBluetooth):@"NSBluetoothPeripheralUsageDescription"}
typedef void (^CallBackBlock)(FPPermissionStatus status);

NS_ASSUME_NONNULL_BEGIN
@interface FPPermission : NSObject
+ (void)requestAuthorizationStatus:(FPPermissionType)type showAlertWhenDenied:(BOOL)alert resultBlock:(CallBackBlock)block;
+ (FPPermissionStatus)mapStatus:(FPPermissionType)type;
+ (void)jumpAppSetting;
@end

NS_ASSUME_NONNULL_END
