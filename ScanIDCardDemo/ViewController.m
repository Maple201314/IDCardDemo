//
//  ViewController.m
//  ScanIDCardDemo
//
//  Created by William on 2019/1/2.
//  Copyright © 2019 William. All rights reserved.
//

#import "ViewController.h"
#import "DXIDCardCameraController.h"

@interface ViewController()<DXIDCardDelegate>
@property (weak, nonatomic) IBOutlet UIButton *frontButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
}
- (IBAction)buttonClick:(id)sender {
    DXIDCardCameraController *vc = [[DXIDCardCameraController alloc] initWithType:front];
    vc.delegate = self;
    [self presentViewController:vc animated:true completion:nil];
}
- (IBAction)button2Click:(id)sender {
    DXIDCardCameraController *vc = [[DXIDCardCameraController alloc] initWithType:reverse];
    vc.delegate = self;
    [self presentViewController:vc animated:true completion:nil];
}

- (void)cameraShootWithImage:(UIImage *)image type:(DXIDCardType)type{
    self.imageView.image = image;
}

@end
