//
//  GLImageView.m
//  03-头像图片放大
//
//  Created by 钟国龙 on 2017/3/20.
//  Copyright © 2017年 guolong. All rights reserved.
//

#import "GLImageView.h"
#import "UIView+GLExtension.h"

@interface GLImageView ()<UIScrollViewDelegate>

@property (nonatomic, weak)UIVisualEffectView *blurBackground;

@property (nonatomic, strong)UIScrollView *scrollView;

@property (nonatomic, strong)UIView *containerView;

@property (nonatomic, strong)UIImageView *imageView;

@property (nonatomic, strong)UIImageView *fromImageView;

@end

@implementation GLImageView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    self.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self addGestureRecognizer:doubleTap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self addGestureRecognizer:longPress];
    
    //设置模糊背景
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    
    effectView.frame = self.frame;
    [self addSubview:effectView];
    
    self.blurBackground = effectView;
    
    //设置scrollView相关属性
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    self.scrollView.delegate = self;
    self.scrollView.bouncesZoom = YES;
    self.scrollView.maximumZoomScale = 3.0;
    self.scrollView.multipleTouchEnabled = YES;
    self.scrollView.alwaysBounceVertical = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    
    [self addSubview:self.scrollView];
    
    //containerView
    self.containerView = [[UIView alloc] init];
    [self.scrollView addSubview:self.containerView];
    
    //imageView
    self.imageView = [[UIImageView alloc] init];
    self.imageView.clipsToBounds = YES;
    self.imageView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    [self.containerView addSubview:self.imageView];
}

- (void)preViewFromImageView:(UIImageView *)fromImageView inContainer:(UIView *)container
{
    _fromImageView = fromImageView;
    fromImageView.hidden = YES;
    [container addSubview:self];
    
    self.containerView.origin = CGPointZero;
    self.containerView.width = self.width;
    
    UIImage *image = fromImageView.image;
    
    // 计算 containerView 的高度
    if (image.size.width / image.size.height > self.height / self.width) {
        self.containerView.height = floor(image.size.height / (image.size.width / self.width));
    } else {
        CGFloat height = image.size.height / image.size.width * self.width;
        if (height < 1 || isnan(height)) height = self.height;
        height = floor(height);
        self.containerView.height = height;
        self.containerView.centerY = self.height / 2;
    }
    
    if (self.containerView.height > self.height && self.containerView.height - self.height <= 1) {
        self.containerView.height = self.height;
    }
    
    self.scrollView.contentSize = CGSizeMake(self.width, MAX(self.containerView.height, self.height));
    [self.scrollView scrollRectToVisible:self.bounds animated:NO];
    
    if (self.containerView.height <= self.height) {
        self.scrollView.alwaysBounceVertical = NO;
    } else {
        self.scrollView.alwaysBounceVertical = YES;
    }
    
    CGRect fromRect = [fromImageView convertRect:fromImageView.bounds toView:self.containerView];
    
    self.imageView.frame = fromRect;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.image = image;
    
    [UIView animateWithDuration:0.18 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
        self.imageView.frame = self.containerView.bounds;
        self.imageView.transform = CGAffineTransformMakeScale(1.01, 1.01);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.18 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
            self.imageView.transform = CGAffineTransformMakeScale(1.00, 1.00);
        } completion:nil];
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.18 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect fromRect = [self.fromImageView convertRect:self.fromImageView.bounds toView:self.containerView];
        self.imageView.contentMode = self.fromImageView.contentMode;
        self.imageView.frame = fromRect;
        self.blurBackground.alpha = 0.01;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.10 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.fromImageView.hidden = NO;
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.containerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    UIView *subView = self.containerView;
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

- (void)singleTap:(UITapGestureRecognizer *)gesture
{
    [self dismiss];
}

- (void)doubleTap:(UITapGestureRecognizer *)gesture
{
    if (self.scrollView.zoomScale > 1.0) {
        [self.scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [gesture locationInView:self.imageView];
        CGFloat newZoomScale = self.scrollView.maximumZoomScale;
        CGFloat xSize = self.width / newZoomScale;
        CGFloat ySize = self.height / newZoomScale;
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x - xSize / 2, touchPoint.y - ySize / 2, xSize, ySize) animated:YES];
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)gesture
{
    // 为了避免弹警告：Warning: Attempt to present <UIAlertController: 0x7fcb1e619e80>  on <ViewController: 0x7fcb1e60f9f0> which is already presenting <UIAlertController: 0x7fcb1e50d2e0>，最好加入状态判断
    if (gesture.state == UIGestureRecognizerStateBegan) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"QuoraDots" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        
        UIViewController *vc = self.viewController;
        [vc presentViewController:alertController animated:YES completion:nil];
    }
}

@end
