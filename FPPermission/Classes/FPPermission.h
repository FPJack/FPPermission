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
    FPPermissionMicrophone,
    FPPermissionCalendars,
    FPPermissionContacts,
    FPPermissionPhoto,
    FPPermissionLocationWhenInUse,
    FPPermissionLocationAlways,
    FPPermissionBluetooth
};
typedef NS_ENUM(NSInteger, FPPermissionStatus) {
    FPPermissionStatusNotDetermined = 0,
    FPPermissionStatusDenied,
    FPPermissionStatusAuthorized,
    FPPermissionStatusRestricted,
    FPPermissionStatusAuthorizedWhenUse,//定位特定多一个返回状态
    FPPermissionStatusPoweredOff//蓝牙定位手机权限关闭状态
};
#define kFPPermissionTitleInfo @{@(FPPermissionCamer):@"相机",\
                               @(FPPermissionPhoto):@"相册",\
                                @(FPPermissionMicrophone):@"麦克风",\
                                @(FPPermissionLocationWhenInUse):@"定位",\
                                @(FPPermissionLocationAlways):@"定位",\
                                @(FPPermissionCalendars):@"日历",\
                                @(FPPermissionContacts):@"通讯录",\
                                @(FPPermissionBluetooth):@"蓝牙"}
#define kFPPermissionDesInfo @{@(FPPermissionCamer):@"NSCameraUsageDescription",\
                             @(FPPermissionPhoto):@"NSPhotoLibraryUsageDescription",\
                             @(FPPermissionMicrophone):@"NSMicrophoneUsageDescription",\
                             @(FPPermissionCalendars):@"NSCalendarsUsageDescription",\
                             @(FPPermissionContacts):@"NSContactsUsageDescription",\
                             @(FPPermissionLocationAlways):@"NSLocationAlwaysUsageDescription",\
                             @(FPPermissionLocationWhenInUse):@"NSLocationWhenInUseUsageDescription",\
                             @(FPPermissionBluetooth):@"NSBluetoothPeripheralUsageDescription"}
typedef void (^FPCallBackBlock)(FPPermissionStatus status);

NS_ASSUME_NONNULL_BEGIN
@interface FPPermission : NSObject
+ (void)requestAuthorizationStatus:(FPPermissionType)type showAlertWhenDenied:(BOOL)alert resultBlock:(FPCallBackBlock)block;
+ (FPPermissionStatus)mapStatus:(FPPermissionType)type;
+ (void)jumpAppSetting;
@end

NS_ASSUME_NONNULL_END
