//
//  FPOpenCamera.h
//  ZhiChongRadar
//
//  Created by fanpeng on 2019/10/25.
//  Copyright © 2019 zhichongjia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
typedef NS_ENUM(NSInteger, CameraType) {
    CameraTypeTakePhoto,
    CameraTypeTakeVideo,
    CameraTypeTakePhotoAndVideo,
};
NS_ASSUME_NONNULL_BEGIN
@interface FPOpenCamera : NSObject
@property (assign, nonatomic) NSTimeInterval videoMaxDuration;
@property (assign,nonatomic)CameraType type;
@property (nonatomic,assign)BOOL allowEditingImage;
@property (nonatomic,assign)BOOL allowEditingVideo;
@property (nonatomic, copy) void (^didFinishTakeVideoHandle)(UIImage *coverImage,PHAsset *asset,NSError *error);
@property (nonatomic, copy) void (^didFinishTakePhotosHandle)(UIImage *image,NSDictionary *info,NSError *error);
+ (instancetype)share;
- (void)openCameraFromVC:(UIViewController*)fromVC;
@end
NS_ASSUME_NONNULL_END
