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
#import <EventKit/EventKit.h>
#import <Contacts/Contacts.h>
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
+ (void)requestAuthorizationStatus:(FPPermissionType)type showAlertWhenDenied:(BOOL)alert resultBlock:(FPCallBackBlock)block{
    if (type == FPPermissionCamer) {
        [self cameraAuthorizationShowAlertWhenDenied:alert result:block];
    }else if (type == FPPermissionPhoto){
        [self photoAuthorizationShowAlertWhenDenied:alert result:block];
    }else if (type == FPPermissionMicrophone){
        [self microphoneAuthorizationShowAlertWhenDenied:alert result:block];
    }else if (type == FPPermissionLocationAlways){
        [self loacationAuthorizationShowAlertWhenDenied:alert permissionType:type result:block];
    }else if (type == FPPermissionLocationWhenInUse){
        [self loacationAuthorizationShowAlertWhenDenied:alert permissionType:type result:block];
    }else if (type == FPPermissionBluetooth){
        [self bluetoothAuthorizationShowAlertWhenDenied:alert result:block];
    }else if (type == FPPermissionCalendars){
        [self calendersAuthorizationShowAlertWhenDenied:alert result:block];
    }else if (type == FPPermissionContacts){
        [self contactsAuthorizationShowAlertWhenDenied:alert result:block];
    }
}
+ (void)contactsAuthorizationShowAlertWhenDenied:(BOOL)alert result:(FPCallBackBlock)block{
    FPPermissionStatus status = [self mapStatus:FPPermissionContacts];
    if (status == FPPermissionStatusNotDetermined) {
        if (@available(iOS 9.0, *)) {
            CNContactStore *contactStore = [[CNContactStore alloc] init];
            [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (block) block([self mapStatus:FPPermissionContacts]);
                });
            }];
        }else{
            __block ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (block) block([self mapStatus:FPPermissionContacts]);
                    if (addressBookRef) {
                        CFRelease(addressBookRef);
                        addressBookRef = NULL;
                    }
                });
            });
        }
    }else if (status == FPPermissionStatusDenied || status == FPPermissionStatusRestricted){
        if (alert) [self manaulShowAuthorization:FPPermissionContacts];
        if (block) block(status);
    }else if (status == FPPermissionStatusAuthorized){
        if (block) block(FPPermissionStatusAuthorized);
    }
}
+ (void)calendersAuthorizationShowAlertWhenDenied:(BOOL)alert result:(FPCallBackBlock)block{
    FPPermissionStatus status = [self mapStatus:FPPermissionCalendars];
    if (status == FPPermissionStatusNotDetermined) {
        EKEventStore *store = [[EKEventStore alloc] init];
        [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                    if (block) block([self mapStatus:FPPermissionCalendars]);
            });
        }];
    }else if (status == FPPermissionStatusDenied || status == FPPermissionStatusRestricted){
        if (alert) [self manaulShowAuthorization:FPPermissionCalendars];
        if (block) block(status);
    }else if (status == FPPermissionStatusAuthorized){
        if (block) block(FPPermissionStatusAuthorized);
    }
}
+ (void)photoAuthorizationShowAlertWhenDenied:(BOOL)alert result:(FPCallBackBlock)block{
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
+ (void)cameraAuthorizationShowAlertWhenDenied:(BOOL)alert result:(FPCallBackBlock)block{
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
+ (void)microphoneAuthorizationShowAlertWhenDenied:(BOOL)alert result:(FPCallBackBlock)block{
    FPPermissionStatus status = [self mapStatus:FPPermissionMicrophone];
    if (status == FPPermissionStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) block([self mapStatus:FPPermissionMicrophone]);
            });
        }];
    }else if (status == FPPermissionStatusDenied || status == FPPermissionStatusRestricted){
        if (alert) [self manaulShowAuthorization:FPPermissionMicrophone];
        if (block) block(status);
    }else if (status == FPPermissionStatusAuthorized){
        if (block) block(FPPermissionStatusAuthorized);
    }
}
+ (void)loacationAuthorizationShowAlertWhenDenied:(BOOL)alert permissionType:(FPPermissionType)type result:(FPCallBackBlock)block{
    FPPermissionStatus status = [self mapStatus:type];
    if (status == FPPermissionStatusNotDetermined) {
        [FPLocationManager.manager startLocationWithDidChangeAuthorizationStatusBlock:^(CLAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) block([self mapStatus:type]);
            });
        }];
        if (type == FPPermissionLocationAlways) {
            [FPLocationManager.manager requestAlwaysAuthorization];
        }else if(type == FPPermissionLocationWhenInUse){
            [FPLocationManager.manager requestWhenInUseAuthorization];
        }
    }else if (status == FPPermissionStatusDenied || status == FPPermissionStatusRestricted){
        if(alert) [self manaulShowAuthorization:type];
        if (block) block(status);
    }else if (status == FPPermissionStatusAuthorized ||status ==
              FPPermissionStatusAuthorizedWhenUse){
        if (block) block(status);
    }else if (status == FPPermissionStatusPoweredOff){
        if (alert) [self showAlertMessage:type];
        if (block) block(status);
    }
}
+ (void)bluetoothAuthorizationShowAlertWhenDenied:(BOOL)alert result:(FPCallBackBlock)block{
    [FPPermission share].blueDelegate = [FPBlueToothDelegate FPBlueToothDelegateBlock:^(CBPeripheralManagerState state) {
        switch (state) {
            case CBPeripheralManagerStatePoweredOff:
                if (alert) [self showAlertMessage:FPPermissionBluetooth];
                if (block) block(FPPermissionStatusPoweredOff);
                break;
            case CBPeripheralManagerStatePoweredOn:
                if (block) block([self mapStatus:FPPermissionBluetooth]);
                break;
            case CBPeripheralManagerStateUnauthorized:
//              if(alert) [self manaulShowAuthorization:FPPermissionBluetooth];
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
    }else if (type == FPPermissionMicrophone) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
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
    }else if (type == FPPermissionLocationWhenInUse || type == FPPermissionLocationAlways){
        if (![CLLocationManager locationServicesEnabled]) return FPPermissionStatusPoweredOff;
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
    }else if (type == FPPermissionCalendars){
        EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
        if (status == EKAuthorizationStatusNotDetermined) {
            return FPPermissionStatusNotDetermined;
        }else if (status == EKAuthorizationStatusRestricted){
            return FPPermissionStatusRestricted;
        }else if (status == EKAuthorizationStatusDenied){
            return FPPermissionStatusDenied;
        }else if (status == EKAuthorizationStatusAuthorized){
            return FPPermissionStatusAuthorized;
        }
    }else if (type == FPPermissionContacts){
        if (@available(iOS 9.0, *)) {
            CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
            if (status == CNAuthorizationStatusNotDetermined) {
                return FPPermissionStatusNotDetermined;
            }else if (status == CNAuthorizationStatusAuthorized){
                return FPPermissionStatusAuthorized;
            }else if (status == CNAuthorizationStatusDenied) {
                return FPPermissionStatusDenied;
            }else if(status == CNAuthorizationStatusRestricted){
                return FPPermissionStatusRestricted;
            }
        } else {
            // Fallback on earlier versions
            //ios 9.0 之前版本
            ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
            if (status == kABAuthorizationStatusNotDetermined) {
                return FPPermissionStatusNotDetermined;
            }else if (status == kABAuthorizationStatusAuthorized){
                return FPPermissionStatusAuthorized;
            }else if (status == kABAuthorizationStatusDenied) {
                return FPPermissionStatusDenied;
            }else if(status == kABAuthorizationStatusRestricted){
                return FPPermissionStatusRestricted;
            }
        }
    }
    return FPPermissionStatusNotDetermined;
}

#pragma mark -跳权限设置界面
+ (void)showAlertMessage:(FPPermissionType)type{
    NSString *title;
    NSString *message;
    if (type == FPPermissionLocationAlways || type == FPPermissionLocationWhenInUse) {
        title = @"手机定位功能已关闭";
        message = @"请前往->设置->隐私->开启定位功能";
    }else if (type == FPPermissionBluetooth){
        title = @"手机蓝牙功能已关闭";
        message = @"请前往->设置->蓝牙->开启蓝牙功能";
    }
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ac1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertVC addAction:ac1];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertVC animated:YES completion:nil];
    });

}
+ (void)manaulShowAuthorization:(FPPermissionType)type{
    NSString *title = [NSString stringWithFormat:@"允许访问你的%@",kFPPermissionTitleInfo[@(type)]];
    NSDictionary* infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *des = [NSString stringWithFormat:@"更好的使用APP%@",infoDic[kFPPermissionDesInfo[@(type)]]];
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:des preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ac1 = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *ac2 = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self jumpAppSetting];
    }];
    [alertVC addAction:ac1];
    [alertVC addAction:ac2];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertVC animated:YES completion:nil];
    });
}
+ (void)jumpAppSetting{
    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([[UIApplication sharedApplication] openURL:url]) [[UIApplication sharedApplication] openURL:url];
}
@end
