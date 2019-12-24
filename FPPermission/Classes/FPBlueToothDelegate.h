//
//  FPBlueToothDelegate.h
//  ZhiChongRadar
//
//  Created by fanpeng on 2019/11/12.
//  Copyright © 2019 zhichongjia. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "FPPermission.h"
NS_ASSUME_NONNULL_BEGIN

@interface FPBlueToothDelegate : CBPeripheralManager<CBPeripheralManagerDelegate>
+ (instancetype)FPBlueToothDelegateBlock:(void (^)(CBPeripheralManagerState state))block;
+ (FPPermissionStatus)status;
@end
NS_ASSUME_NONNULL_END
