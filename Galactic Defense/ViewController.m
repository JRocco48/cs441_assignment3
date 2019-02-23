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
    UIImageView * enemy;
    NSMutableArray * lasers;
    float duration;
    int laserAlternator;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBackground];
    [self setupPlayer];
    [self setupEnemy];
    
}

- (void)setupEnemy {
    enemy = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 100, 100)];
    enemy.animationImages = [NSArray arrayWithObjects:
                             [UIImage imageNamed:@"enemy1"],
                             [UIImage imageNamed:@"enemy2"],
                             [UIImage imageNamed:@"enemy3"], nil];
    enemy.animationDuration = 0.3f;
    [enemy setAnimationRepeatCount:0];
    [self.view addSubview:enemy];
    [enemy startAnimating];
}

- (void)setupPlayer {
    player = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-75, self.view.frame.size.height-120, 80, 80)];
    player.animationImages = [NSArray arrayWithObjects:
                              [UIImage imageNamed:@"player0"],
                              [UIImage imageNamed:@"player1"],
                              [UIImage imageNamed:@"player2"], nil];
    player.animationDuration = 0.3f;
    [player setAnimationRepeatCount:0];
    [self.view addSubview:player];
    [player startAnimating];
    
   // NSMutableArray * lasers = [[NSMutableArray alloc] init];
   [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(spawnLaser:) userInfo:nil repeats:YES];

}

-(void)spawnLaser: (NSTimer *) timer {
    UIImageView * laser = [[UIImageView alloc] initWithFrame:CGRectMake(player.center.x-40, player.center.y-40, 80, 80)];
    laser.image = [UIImage imageNamed:@"laser"];
    
    [UIView animateWithDuration:2
                          delay:0.0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         [laser setFrame:CGRectMake(laser.frame.size.width, laser.center.x, laser.frame.size.height, self.view.frame.size.height)];
                     }
                     completion:^(BOOL finished){
                         NSLog(@"DELETE!");
                     }];
    [self.view addSubview:laser];
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
    duration = 8;
    [self animate];
}

- (void)animate {
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self->bgView1.frame = CGRectOffset(self->bgView1.frame, 0, self->bgView1.frame.size.height);
        self->bgView2.frame = CGRectOffset(self->bgView2.frame, 0, self->bgView2.frame.size.height);
    } completion:^(BOOL done) {
        if (done) {
            self->bgView1.frame = CGRectOffset(self->bgView1.frame, 0, -2*self->bgView1.frame.size.height);
            [UIView animateWithDuration:self->duration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                self->bgView2.frame = CGRectOffset(self->bgView2.frame, 0, self->bgView2.frame.size.height);
                self->bgView1.frame = CGRectOffset(self->bgView1.frame, 0, self->bgView1.frame.size.height);
            } completion:^(BOOL done) {
                if (done) {
                    self->bgView2.frame = CGRectOffset(self->bgView2.frame, 0, -2*self->bgView2.frame.size.height);
                    [self animate];
                }
            }];
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:touch.view];
    [UIView animateWithDuration:(1.0f) delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self->player.center = touchLocation;
    }completion:nil];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:touch.view];
    self->player.center = touchLocation;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return NO;
}


@end
