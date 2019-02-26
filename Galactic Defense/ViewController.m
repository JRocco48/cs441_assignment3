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
    
    CGPoint touchOrigin;
    CGPoint playerOrigin;
    
    NSMutableArray * lasers;
    NSMutableArray * enemies;
    
    float duration;
    int laserAlternator;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    lasers = [NSMutableArray array];
    enemies = [NSMutableArray array];
    [super viewDidLoad];
    [self setupBackground];
    [self setupPlayer];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(spawnEnemy:) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkCollisions:) userInfo:nil repeats:YES];
}

- (void)spawnEnemy: (NSTimer *) timer {
    UIImageView * enemy = [[UIImageView alloc] initWithFrame:CGRectMake(arc4random() % (int)(self.view.frame.size.width - 50), -100, 80, 80)];
    enemy.animationImages = [NSArray arrayWithObjects:
                             [UIImage imageNamed:@"enemy1"],
                             [UIImage imageNamed:@"enemy2"],
                             [UIImage imageNamed:@"enemy3"], nil];
    enemy.animationDuration = 0.3f;
    [enemy setAnimationRepeatCount:0];
    [self.view addSubview:enemy];
    [enemy startAnimating];
    
    [enemies addObject:enemy];
    [UIView animateWithDuration:7
                          delay:0.0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         [enemy setFrame:CGRectMake(enemy.frame.origin.x, self.view.frame.size.height + 100, 100, 100)];
                     }
                     completion:^(BOOL finished){
                         enemy.image = nil;
                     }];
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
    
   [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(shootLaser:) userInfo:nil repeats:YES];

}

-(void)shootLaser: (NSTimer *) timer {
    int laserStart;
    if(laserAlternator == 0) {
        laserAlternator = 1;
        laserStart = player.center.x-11;
    } else {
        laserAlternator = 0;
        laserStart = player.center.x - 66;
    }
    UIImageView * laser = [[UIImageView alloc] initWithFrame:CGRectMake(laserStart, player.center.y-32, 80, 80)];
    laser.image = [UIImage imageNamed:@"laser"];
    [UIView animateWithDuration:player.frame.origin.y/400
                        delay:0.0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         [laser setFrame:CGRectMake(laserStart, -100, 80, 80)];
                     }
                     completion:^(BOOL finished){
                         laser.image = nil;
                     }];
    [self.view addSubview:laser];
    [self.view bringSubviewToFront:player];
    
    [lasers addObject:laser];
}

- (void)checkCollisions: (NSTimer *) timer {
    for(UIImageView * enemy in enemies) {
        for(UIImageView * laser in lasers) {
            if(CGRectContainsPoint(CGRectMake(enemy.layer.presentationLayer.frame.origin.x + 40,
                                              enemy.layer.presentationLayer.frame.origin.y + 70,
                                              12,
                                              12),
                                   CGPointMake(laser.layer.presentationLayer.frame.origin.x + 40,
                                               laser.layer.presentationLayer.frame.origin.y + 40))) {
                [enemy.layer removeAllAnimations];
                [laser.layer removeAllAnimations];            }
        }
    }
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
    touchOrigin = [touch locationInView:touch.view];
    playerOrigin = self->player.center;
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:touch.view];
    CGFloat changedX = touchLocation.x - touchOrigin.x;
    CGFloat changedY = touchLocation.y - touchOrigin.y;
    CGFloat newX = playerOrigin.x + changedX;
    CGFloat newY = playerOrigin.y + changedY;
    if(playerOrigin.x + changedX > self.view.frame.size.width) newX = self.view.frame.size.width;
    if(playerOrigin.x + changedX < 0) newX = 0;
    if(playerOrigin.y + changedY > self.view.frame.size.height) newY = self.view.frame.size.height;
    if(playerOrigin.y + changedY < 0) newY = 0;
    self->player.center = CGPointMake(newX, newY);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return NO;
}


@end
