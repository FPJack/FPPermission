#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "FPBlueToothDelegate.h"
#import "FPLocationManager.h"
#import "FPOpenCamera.h"
#import "FPPermission.h"
#import "FPVideoEditVC.h"

FOUNDATION_EXPORT double FPPermissionVersionNumber;
FOUNDATION_EXPORT const unsigned char FPPermissionVersionString[];

