//
//  FPOpenCamera.m
//  ZhiChongRadar
//
//  Created by fanpeng on 2019/10/25.
//  Copyright © 2019 zhichongjia. All rights reserved.
//

#import "FPOpenCamera.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "FPPermission.h"
static FPOpenCamera *camera;
@interface FPOpenCamera()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic,copy)void(^completion)(UIImage* image,NSError* error,BOOL cancel);
@property (nonatomic, strong) UIImagePickerController *imagePickerVc;
@end
@implementation FPOpenCamera
+ (instancetype)share{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        camera = [FPOpenCamera new];
    });
    return camera;
}
- (UIImagePickerController *)imagePickerVc {
    if (_imagePickerVc == nil) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.delegate = self;
    }
    return _imagePickerVc;
}
- (void)openCameraFromVC:(UIViewController*)fromVC{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: sourceType]) {
        self.imagePickerVc.sourceType = sourceType;
        NSMutableArray *mediaTypes = [NSMutableArray array];
        if (self.type == CameraTypeTakePhoto) {
            self.imagePickerVc.allowsEditing = self.allowEditingImage;
            [mediaTypes addObject:(NSString *)kUTTypeImage];
        }
        if (self.type == CameraTypeTakeVideo) {
            [mediaTypes addObject:(NSString *)kUTTypeMovie];
            self.imagePickerVc.videoMaximumDuration = self.videoMaxDuration;
            self.imagePickerVc.allowsEditing = self.allowEditingVideo;
        }
        if (self.type == CameraTypeTakePhotoAndVideo) {
            self.imagePickerVc.allowsEditing = self.allowEditingImage;
            [mediaTypes addObject:(NSString *)kUTTypeImage];
            [mediaTypes addObject:(NSString *)kUTTypeMovie];
            self.imagePickerVc.videoMaximumDuration = self.videoMaxDuration;
            self.imagePickerVc.allowsEditing = self.allowEditingVideo;
        }
        self.imagePickerVc.mediaTypes= mediaTypes;
        [fromVC presentViewController:self.imagePickerVc animated:YES completion:nil];
    } else {
        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
}
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    [FPPermission requestAuthorizationStatus:FPPermissionPhoto showAlertWhenDenied:YES resultBlock:^(FPPermissionStatus status) {
        if (status == FPPermissionStatusAuthorized) {
            if ([type isEqualToString:@"public.image"]) {
                UIImage *photo = [info objectForKey:UIImagePickerControllerOriginalImage];
                NSDictionary *meta = [info objectForKey:UIImagePickerControllerMediaMetadata];
                if (photo) {
                    [self savePhotoWithImage:photo meta:meta location:nil completion:^(PHAsset *asset, NSError *error){
                        if (!error) {
                           PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                           options.resizeMode = PHImageRequestOptionsResizeModeFast;
                           [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                               UIImage *resultImage = [UIImage imageWithData:imageData];
                               resultImage = [self fixOrientation:resultImage];
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   if (!self.didFinishTakePhotosHandle) return ;
                                    self.didFinishTakePhotosHandle(resultImage, info, error);
                               });
                           }];
                        }
                    }];
                }
            } else if ([type isEqualToString:@"public.movie"]) {
                NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
                if (videoUrl) {
                    [self saveVideoWithUrl:videoUrl location:nil completion:^(PHAsset *pAsset, NSError *error) {
                        if (!error) {
                            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
                            options.version = PHImageRequestOptionsVersionCurrent;
                            options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
                            [[PHImageManager defaultManager] requestAVAssetForVideo:pAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                                AVURLAsset *urlAsset = (AVURLAsset *)asset;
                                UIImage *coverImage = [self getVideoPreViewImage:urlAsset.URL];
                                coverImage = [self fixOrientation:coverImage];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                   if (!self.didFinishTakeVideoHandle) return ;
                                   self.didFinishTakeVideoHandle(coverImage, pAsset, error);
                                });
                            }];
                        }
                    }];
                }
            }
        }
    }];
}
- (void)savePhotoWithImage:(UIImage *)image meta:(NSDictionary *)meta location:(CLLocation *)location completion:(void (^)(PHAsset *asset, NSError *error))completion {
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss-SSS"];
    NSString *path = [NSTemporaryDirectory() stringByAppendingFormat:@"image-%@.jpg", [formater stringFromDate:[NSDate date]]];
    NSURL *tmpURL = [NSURL fileURLWithPath:path];
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)tmpURL, kUTTypeJPEG, 1, NULL);
    CGImageDestinationAddImageFromSource(destination, source, 0, (__bridge CFDictionaryRef)meta);
    CGImageDestinationFinalize(destination);
    CFRelease(source);
    CFRelease(destination);
    
    __block NSString *localIdentifier = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:tmpURL];
        localIdentifier = request.placeholderForCreatedAsset.localIdentifier;
        if (location) {
            request.location = location;
        }
        request.creationDate = [NSDate date];
    } completionHandler:^(BOOL success, NSError *error) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success && completion) {
                PHAsset *asset = [[PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil] firstObject];
                completion(asset, nil);
            } else if (error) {
                NSLog(@"保存照片出错:%@",error.localizedDescription);
                if (completion) {
                    completion(nil, error);
                }
            }
        });
    }];
}
- (void)saveVideoWithUrl:(NSURL *)url location:(CLLocation *)location completion:(void (^)(PHAsset *asset, NSError *error))completion {
    __block NSString *localIdentifier = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *request = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
        localIdentifier = request.placeholderForCreatedAsset.localIdentifier;
        if (location) {
            request.location = location;
        }
        request.creationDate = [NSDate date];
    } completionHandler:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success && completion) {
                PHAsset *asset = [[PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil] firstObject];
                completion(asset, nil);
            } else if (error) {
                NSLog(@"保存视频出错:%@",error.localizedDescription);
                if (completion) {
                    completion(nil, error);
                }
            }
        });
    }];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
// 获取视频第一帧
- (UIImage*) getVideoPreViewImage:(NSURL *)path
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
}
- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
@end
