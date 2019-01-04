//
//  DXIDCardFloatingView.m
//  ScanIDCardDemo
//
//  Created by William on 2019/1/4.
//  Copyright © 2019 William. All rights reserved.
//

#import "DXIDCardFloatingView.h"
@interface DXIDCardFloatingView()

@property(nonatomic,strong) CAShapeLayer *IDCardWindowLayer;
@property(nonatomic,strong) NSBundle *resouceBundle;

@end
@implementation DXIDCardFloatingView

BOOL isIPhone5or5cor5sorSE;//  = UIScreen.mainScreen.bounds.size.height == 568.0 ? true:false;
BOOL isIPhone6or6sor7;//  = kScreenH == 667.0;

- (void)initWithType:(DXIDCardType)type{
    self.frame = UIScreen.mainScreen.bounds;
    self.type = type;
    isIPhone5or5cor5sorSE  = UIScreen.mainScreen.bounds.size.height == 568.0 ? true:false;
    isIPhone6or6sor7  = UIScreen.mainScreen.bounds.size.height == 667.0 ? true:false;

    _IDCardWindowLayer = [[CAShapeLayer alloc] init];
    _IDCardWindowLayer.position = self.layer.position;
    _IDCardWindowLayer.cornerRadius = 15;
    _IDCardWindowLayer.borderColor = UIColor.whiteColor.CGColor;
    _IDCardWindowLayer.borderWidth = 2;
    
    _resouceBundle = [NSBundle bundleWithPath:[[NSBundle alloc] pathForResource:@"DXIDCardCamera" ofType:@"bundle"]];
    
    self.backgroundColor = UIColor.clearColor;
    CGFloat width = isIPhone5or5cor5sorSE ? 240 : (isIPhone6or6sor7 ? 240 : 270);
    _IDCardWindowLayer.bounds =  CGRectMake(0, 0, width, width*1.574);
    [self.layer addSublayer:_IDCardWindowLayer];
    // 最里层镂空
    UIBezierPath *transparentRoundedRectPath = [UIBezierPath
                bezierPathWithRoundedRect:_IDCardWindowLayer.frame cornerRadius:_IDCardWindowLayer.cornerRadius];
    
    // 最外层背景
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:UIScreen.mainScreen.bounds];
    [path appendPath:transparentRoundedRectPath];
    path.usesEvenOddFillRule = true;
    
    CAShapeLayer *fillLayer = [[CAShapeLayer alloc] init];
    fillLayer.path = path.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    fillLayer.fillColor = UIColor.blackColor.CGColor;
    fillLayer.opacity = 0.6;
    [self.layer addSublayer:fillLayer];
    
    // 提示标签
    UILabel *textLabel = [UILabel new];
    NSString* text = type == front ? @"对齐身份证正面并点击拍照" : @"对齐身份证背面并点击拍照";
    textLabel.text = text;
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.font = [UIFont systemFontOfSize:14];
    textLabel.textColor = UIColor.whiteColor;
    [self addSubview:textLabel];
    
    CGFloat kScreenH = UIScreen.mainScreen.bounds.size.height;
    CGFloat kScreenW = UIScreen.mainScreen.bounds.size.width;
    CGFloat w  = kScreenH;
    CGFloat h  = 20;
    CGFloat x  = (kScreenW - w)/2 -_IDCardWindowLayer.frame.size.width/2-20;
    CGFloat y  = (kScreenH - h)/2;
    
    textLabel.frame = CGRectMake(x, y, w, h);
    textLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
    
    CGFloat facePathWidth   = 0;
    CGFloat facePathHeight  = 0;
    UIImage* image;
    
    if(type == front) {
        facePathWidth = isIPhone5or5cor5sorSE ? 95 : (isIPhone6or6sor7 ? 120 : 150);
        facePathHeight = facePathWidth * 0.812;
        image = [UIImage imageWithContentsOfFile:[_resouceBundle pathForResource:@"xuxian@2x" ofType:@"png"]];
    }else{
        facePathWidth = isIPhone5or5cor5sorSE ? 40 : (isIPhone6or6sor7 ? 80 : 100);
        facePathHeight = facePathWidth;
        image = [UIImage imageWithContentsOfFile:[_resouceBundle pathForResource:@"Page 1@2x" ofType:@"png"]];
    }
    // 国徽、头像
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    imageView.transform = CGAffineTransformMakeRotation(M_PI_2);
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:imageView];
    
    CGFloat imageX  = 0;
    CGFloat imageY  = 0;
    CGFloat imageW  = facePathWidth;
    CGFloat imageH  = facePathHeight;
    if (type == front) {
        imageX = (kScreenW-imageW)/2;
        imageY = (kScreenH - imageH)/2 + _IDCardWindowLayer.frame.size.height/2 - facePathWidth/2 - 30;
    }else{
        imageX = (kScreenW-imageW)/2+_IDCardWindowLayer.frame.size.width/2 - facePathHeight/2 - 25;
        imageY = (kScreenH - imageH)/2-_IDCardWindowLayer.frame.size.height/2 + facePathWidth/2 + 20;
    }
    imageView.frame = CGRectMake(imageX, imageY, imageW, imageH);
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
