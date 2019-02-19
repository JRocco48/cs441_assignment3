//
//  ViewController.m
//  Galactic Defense
//
//  Created by John Rocco on 2/18/19.
//  Copyright © 2019 John Rocco. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    UIImageView * bgView1;
    UIImageView * bgView2;
    UIImageView * player;
    float duration;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBackground];
    player = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 75, self.view.frame.size.height - 150, 150, 150)];
    [player setImage:[UIImage imageNamed:@"player.png"]];

    [self.view addSubview:player];
}

// Implementation for scrolling background found at https://www.reddit.com/r/ObjectiveC/comments/1zqhhn/help_with_an_infinite_vertically_scrolling/

- (void)setupBackground {
    UIImage * background = [UIImage imageNamed:@"background.jpg"];
    bgView1 = [[UIImageView alloc] initWithFrame:self.view.frame];
    bgView2 = [[UIImageView alloc] initWithFrame:CGRectOffset(self.view.frame, 0, -self.view.frame.size.height)];
    [bgView1 setImage:background];
    [bgView2 setImage:background];
    [self.view addSubview:bgView1];
    [self.view addSubview:bgView2];
    [self.view bringSubviewToFront:bgView1];
    duration = 6;
    [self animate];
}

- (void)animate {
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        bgView1.frame = CGRectOffset(bgView1.frame, 0, bgView1.frame.size.height);
        bgView2.frame = CGRectOffset(bgView2.frame, 0, bgView2.frame.size.height);
    } completion:^(BOOL done) {
        if (done) {
            bgView1.frame = CGRectOffset(bgView1.frame, 0, -2*bgView1.frame.size.height);
            [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                bgView2.frame = CGRectOffset(bgView2.frame, 0, bgView2.frame.size.height);
                bgView1.frame = CGRectOffset(bgView1.frame, 0, bgView1.frame.size.height);
            } completion:^(BOOL done) {
                if (done) {
                    bgView2.frame = CGRectOffset(bgView2.frame, 0, -2*bgView2.frame.size.height);
                    [self animate];
                }
            }];
        }
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return NO;
}


@end
