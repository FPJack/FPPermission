//
//  FPVideoEditVC.h
//  test
//
//  Created by fanpeng on 2019/12/11.
//  Copyright © 2019 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface FPVideoEditVC : UIVideoEditorController
@property (nonatomic,copy,nullable)void (^callBlock)(PHAsset* __nullable pAsset,UIImage * __nullable coverImage,NSError * __nullable error);
@end

NS_ASSUME_NONNULL_END
