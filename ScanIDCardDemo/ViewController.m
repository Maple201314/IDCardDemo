//
//  ViewController.m
//  ScanIDCardDemo
//
//  Created by William on 2019/1/2.
//  Copyright © 2019 William. All rights reserved.
//

#import "ViewController.h"
#import "DXIDCardCameraController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *frontButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
}
- (IBAction)buttonClick:(id)sender {
    DXIDCardCameraController *vc = [[DXIDCardCameraController alloc] initWithType:front];
    [self presentViewController:vc animated:true completion:nil];
}
- (IBAction)button2Click:(id)sender {
    
}


@end
