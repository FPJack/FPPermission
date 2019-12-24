//
//  Permission.m
//  ZhiChongRadar
//
//  Created by fanpeng on 2019/10/24.
//  Copyright © 2019 zhichongjia. All rights reserved.
//

#import "FPPermission.h"
#import <Photos/PHPhotoLibrary.h>
#import "FPBlueToothDelegate.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <AVFoundation/AVFoundation.h>
#import "FPLocationManager.h"
#import <UIKit/UIKit.h>
typedef void (^StatusBlock)(FPPermissionStatus);
@interface FPPermission()<CLLocationManagerDelegate>
@property (nonatomic,strong)FPBlueToothDelegate *blueDelegate;
@end
@implementation FPPermission
+ (instancetype)share{
    static FPPermission* permission;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        permission = [[FPPermission alloc] init];
    });
    return permission;
}
+ (void)requestAuthorizationStatus:(FPPermissionType)type showAlertWhenDenied:(BOOL)alert resultBlock:(CallBackBlock)block{
    if (type == FPPermissionCamer) {
        [self cameraAuthorizationShowAlertWhenDenied:alert result:block];
    }else if (type == FPPermissionPhoto){
        [self photoAuthorizationShowAlertWhenDenied:alert result:block];
    }else if (type == FPPermissionLocation){
        [self loacationAuthorizationShowAlertWhenDenied:alert result:block];
    }else if (type == FPPermissionBluetooth){
        [self bluetoothAuthorizationShowAlertWhenDenied:alert result:block];
    }
}
+ (void)photoAuthorizationShowAlertWhenDenied:(BOOL)alert result:(CallBackBlock)block{
    FPPermissionStatus status = [self mapStatus:FPPermissionPhoto];
    if (status == FPPermissionStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) block([self mapStatus:FPPermissionPhoto]);
            });
        }];
    }else if (status == FPPermissionStatusDenied || status == FPPermissionStatusRestricted){
        if (alert) [self manaulShowAuthorization:FPPermissionPhoto];
        if (block) block(status);
    }else if (status == FPPermissionStatusAuthorized){
        if (block) block(FPPermissionStatusAuthorized);
    }
}
+ (void)cameraAuthorizationShowAlertWhenDenied:(BOOL)alert result:(CallBackBlock)block{
    FPPermissionStatus status = [self mapStatus:FPPermissionCamer];
    if (status == FPPermissionStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) block([self mapStatus:FPPermissionCamer]);
            });
        }];
    }else if (status == FPPermissionStatusDenied || status == FPPermissionStatusRestricted){
        if (alert) [self manaulShowAuthorization:FPPermissionCamer];
        if (block) block(status);
    }else if (status == FPPermissionStatusAuthorized){
        if (block) block(FPPermissionStatusAuthorized);
    }
}
+ (void)loacationAuthorizationShowAlertWhenDenied:(BOOL)alert result:(CallBackBlock)block{
    FPPermissionStatus status = [self mapStatus:FPPermissionLocation];
    if (status == FPPermissionStatusNotDetermined) {
        [FPLocationObject startLocationWithDidChangeAuthorizationStatusBlock:^(CLAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) block([self mapStatus:FPPermissionLocation]);
            });
        }];
    }else if (status == FPPermissionStatusDenied || status == FPPermissionStatusRestricted){
        if(alert) [self manaulShowAuthorization:FPPermissionLocation];
        if (block) block(status);
    }else if (status == FPPermissionStatusAuthorized ||status == \
              FPPermissionStatusAuthorizedWhenUse){
        if (block) block(status);
    }
}
+ (void)bluetoothAuthorizationShowAlertWhenDenied:(BOOL)alert result:(CallBackBlock)block{
    [FPPermission share].blueDelegate = [FPBlueToothDelegate FPBlueToothDelegateBlock:^(CBPeripheralManagerState state) {
        switch (state) {
            case CBPeripheralManagerStatePoweredOff:
                if (block) block(FPPermissionStatusPoweredOff);
                break;
            case CBPeripheralManagerStatePoweredOn:
                if (block) block([self mapStatus:FPPermissionBluetooth]);
                break;
            case CBPeripheralManagerStateUnauthorized:
                if(alert) [self manaulShowAuthorization:FPPermissionBluetooth];
                if (block) block([self mapStatus:FPPermissionBluetooth]);
                break;
            default:
                break;
        }
    }];
}

+ (FPPermissionStatus)mapStatus:(FPPermissionType)type{
    if (type == FPPermissionCamer) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusNotDetermined) {
            return FPPermissionStatusNotDetermined;
        }else if (status == AVAuthorizationStatusAuthorized){
            return FPPermissionStatusAuthorized;
        }else if (status == AVAuthorizationStatusRestricted){
            return FPPermissionStatusRestricted;
        }else if (status == AVAuthorizationStatusDenied){
            return FPPermissionStatusDenied;
        }
    }else if (type == FPPermissionPhoto){
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusNotDetermined) {
            return FPPermissionStatusNotDetermined;
        }else if (status == PHAuthorizationStatusAuthorized){
            return FPPermissionStatusAuthorized;
        }else if (status == PHAuthorizationStatusRestricted){
            return FPPermissionStatusRestricted;
        }else if (status == PHAuthorizationStatusDenied){
            return FPPermissionStatusDenied;
        }
    }else if (type == FPPermissionLocation){
        CLAuthorizationStatus status =  [CLLocationManager authorizationStatus];
        if (status == kCLAuthorizationStatusNotDetermined) {
            return FPPermissionStatusNotDetermined;
        }else if (status == kCLAuthorizationStatusRestricted){
            return FPPermissionStatusRestricted;
        }else if (status == kCLAuthorizationStatusDenied){
            return FPPermissionStatusDenied;
            
        }else if (status == kCLAuthorizationStatusAuthorizedAlways){
            return FPPermissionStatusAuthorized;
            
        }else if (status == kCLAuthorizationStatusAuthorizedWhenInUse){
            return FPPermissionStatusAuthorizedWhenUse;
        }
    }else if (type == FPPermissionBluetooth){
        
        return [FPBlueToothDelegate status];
    }
    return FPPermissionStatusNotDetermined;
}

#pragma mark -跳权限设置界面
+ (void)manaulShowAuthorization:(FPPermissionType)type{
    NSString *title = [NSString stringWithFormat:@"允许访问你的%@",kPermissionTitleInfo[@(type)]];
    NSDictionary* infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *des = [NSString stringWithFormat:@"更好的使用APP%@",infoDic[kPermissionDesInfo[@(type)]]];
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:des preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ac1 = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *ac2 = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self jumpAppSetting];
    }];
    [alertVC addAction:ac1];
    [alertVC addAction:ac2];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertVC animated:YES completion:nil];
    });
}
+ (void)jumpAppSetting{
    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([[UIApplication sharedApplication] openURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}
@end
