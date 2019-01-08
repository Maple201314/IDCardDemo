//
//  DXIDCardCameraController.h
//  ScanIDCardDemo
//
//  Created by William on 2019/1/4.
//  Copyright © 2019 William. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXIDCardFloatingView.h"

@protocol DXIDCardDelegate<NSObject>
- (void) cameraShootWithImage:(UIImage*)image type:(DXIDCardType) type;
@end

@interface DXIDCardCameraController : UIViewController


@property(nonatomic,weak) id<DXIDCardDelegate> delegate;

- (instancetype)initWithType: (DXIDCardType)type;

@end
