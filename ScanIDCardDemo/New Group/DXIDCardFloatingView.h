//
//  DXIDCardFloatingView.h
//  ScanIDCardDemo
//
//  Created by William on 2019/1/4.
//  Copyright © 2019 William. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    front,
    reverse
} DXIDCardType;

@interface DXIDCardFloatingView : UIView

@property(nonatomic,assign) DXIDCardType type;
@property(nonatomic,strong) CAShapeLayer *IDCardWindowLayer;
@property(nonatomic,strong)  UILabel *textLabel;

- (void)initWithType:(DXIDCardType)type;
@end

NS_ASSUME_NONNULL_END
