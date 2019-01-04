//
//  DXIDCardCameraController.h
//  ScanIDCardDemo
//
//  Created by William on 2019/1/4.
//  Copyright © 2019 William. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXIDCardFloatingView.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^cameraDidFinishShootWithCameraImage)(UIImage*);
typedef void(^cameraDidFinishCancel)(void);

@interface DXIDCardCameraController : UIViewController

@property(nonatomic,assign) cameraDidFinishShootWithCameraImage finishImage;
@property(nonatomic,assign) cameraDidFinishCancel finishCancel;

- (instancetype)initWithType: (DXIDCardType)type;

@end

NS_ASSUME_NONNULL_END
