//
//  FPVideoEditVC.m
//  test
//
//  Created by fanpeng on 2019/12/11.
//  Copyright © 2019 Mac. All rights reserved.
//

#import "FPVideoEditVC.h"
@interface FPVideoEditVC ()<UINavigationControllerDelegate,UIVideoEditorControllerDelegate>

@end

@implementation FPVideoEditVC
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
}
- (void)videoEditorController:(UIVideoEditorController *)editor didSaveEditedVideoToPath:(NSString *)editedVideoPath{
    NSLog(@"didSaveEditedVideoToPath");
    NSURL *url = [NSURL fileURLWithPath:editedVideoPath];
    if (!url) return;
    __weak typeof(self) weakSelf = self;
    [self saveVideoWithUrl:url location:nil completion:^(PHAsset *pAsset, NSError *error) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        [[PHImageManager defaultManager] requestAVAssetForVideo:pAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            AVURLAsset *urlAsset = (AVURLAsset *)asset;
            UIImage *coverImage = [self getVideoPreViewImage:urlAsset.URL];
            dispatch_async(dispatch_get_main_queue(), ^{
               @synchronized (self) {
                   if (weakSelf.callBlock) {
                       weakSelf.callBlock(pAsset,coverImage, nil);
                       weakSelf.callBlock = nil;
                   }
               }
            });
        }];
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
}
- (void)videoEditorController:(UIVideoEditorController *)editor didFailWithError:(NSError *)error{
    if (self.callBlock) {
        self.callBlock(nil,nil, error);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
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
@end
