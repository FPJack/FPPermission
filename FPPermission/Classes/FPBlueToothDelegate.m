//
//  FPBlueToothDelegate.m
//  ZhiChongRadar
//
//  Created by fanpeng on 2019/11/12.
//  Copyright © 2019 zhichongjia. All rights reserved.
//

#import "FPBlueToothDelegate.h"
@interface FPBlueToothDelegate()
@property (nonatomic,copy)void (^callBlock)(CBPeripheralManagerState state);
@end
@implementation FPBlueToothDelegate
+ (instancetype)FPBlueToothDelegateBlock:(void (^)(CBPeripheralManagerState state))block{
        FPBlueToothDelegate* instance = [[FPBlueToothDelegate alloc] initWithDelegate:nil queue:dispatch_get_global_queue(0, 0)];
        instance.callBlock = block;
        instance.delegate = instance;
    return instance;
}
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.callBlock) self.callBlock(((CBPeripheralManagerState)peripheral.state));
    });
}
+ (FPPermissionStatus)status{
    if (@available(iOS 13.1, *)) {
        switch ([self authorization]) {
            case CBManagerAuthorizationNotDetermined:
                    return FPPermissionStatusNotDetermined;
                    break;
                case CBManagerAuthorizationRestricted:
                    return FPPermissionStatusRestricted;
                    break;
                case CBManagerAuthorizationDenied:
                    return FPPermissionStatusDenied;
                    break;
                case CBManagerAuthorizationAllowedAlways:
                    return FPPermissionStatusAuthorized;
                    break;
            default:
                break;
        }
    } else {
        switch ([self authorizationStatus]) {
            case CBPeripheralManagerAuthorizationStatusNotDetermined:
                    return FPPermissionStatusNotDetermined;
                    break;
                case CBPeripheralManagerAuthorizationStatusRestricted:
                    return FPPermissionStatusRestricted;
                    break;
                case CBPeripheralManagerAuthorizationStatusDenied:
                    return FPPermissionStatusDenied;
                    break;
                case CBPeripheralManagerAuthorizationStatusAuthorized:
                    return FPPermissionStatusAuthorized;
                    break;
            default:
                break;
        }
    }
}
@end
