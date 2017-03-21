//
//  ViewController.m
//  03-头像图片放大
//
//  Created by 钟国龙 on 2017/3/20.
//  Copyright © 2017年 guolong. All rights reserved.
//

#import "ViewController.h"

#import "GLImageView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *photoView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.photoView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayLargePhoto)];
    [self.photoView addGestureRecognizer:tap];
    
    
}

- (void)displayLargePhoto {
    GLImageView *previewer = [[GLImageView alloc] initWithFrame:self.view.frame];
    [previewer preViewFromImageView:self.photoView inContainer:self.view];
}



@end
