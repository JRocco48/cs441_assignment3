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
    __weak IBOutlet UILabel *scoreLabel;
    
    int currentLine;
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    scoreLabel.text = @"0";
    lasers = [NSMutableArray array];
    enemies = [NSMutableArray array];
    currentLine = 0;
    
    [super viewDidLoad];
    [self setupBackground];
    [self setupPlayer];
    
    [self levelLoop];
    
}

- (void)levelLoop {
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(playLine:) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(checkCollisions:) userInfo:nil repeats:YES];
}

- (void) playLine: (NSTimer*) timer {
    
    NSArray *lines =  @[@"OxxxxxxxxO",
                        @"xOxxxxxxOx",
                        @"xxOxxxxOxx",
                        @"xxxOxxOxxx",
                        @"xxxxOOxxxx",
                        @"xxxxOOxxx",
                        @"xxxOxxOxxx",
                        @"xxOxxxxOxx",
                        @"xOxxxxxxOx",
                        @"OxxxxxxxxO",
                        @"xxxxxxxxxx",
                        @"xxxxxxxxxx",
                        @"xxxxxxxxxx",
                        @"xxxxxxxxxx",
                        @"xxxxxxxxxx",
                        @"xxxxxxxxxx",
                        @"xxxOxxOxxx",
                        @"xxOxxxxOxx",
                        @"xxxOxxOxxx",
                        @"xxxxOOxxxx"];
    
    if([lines count]  > currentLine) {
        for(int i = 0; i < [lines[currentLine] length]; i++) {
            if([lines[currentLine] characterAtIndex:i] == 'O') [self spawnEnemyAtX:(i) * self.view.frame.size.width/11 withSpeed:12];
        }
        currentLine++;
    }
}

- (void)spawnEnemyAtX: (int) x withSpeed: (int) speed {
    UIImageView * enemy;
    
    int random = rand() % 2;
    if (random == 1) {
        enemy = [[UIImageView alloc] initWithFrame:CGRectMake(x, -100, 80, 80)];
        enemy.animationImages = [NSArray arrayWithObjects:
                                 [UIImage imageNamed:@"enemy1"],
                                 [UIImage imageNamed:@"enemy2"],
                                 [UIImage imageNamed:@"enemy3"], nil];
    } else {
        int randsize = (rand() % 40) + 20;
        enemy = [[UIImageView alloc] initWithFrame:CGRectMake(x, -100, randsize, randsize)];
        enemy.animationImages = [NSArray arrayWithObjects:
                                 [UIImage imageNamed:@"meteor1"],
                                 [UIImage imageNamed:@"meteor2"],
                                 [UIImage imageNamed:@"meteor3"],
                                 [UIImage imageNamed:@"meteor4"], nil];
    }
    enemy.animationDuration = 0.3f;
    [enemy setAnimationRepeatCount:0];
    [self.view addSubview:enemy];
    [enemy startAnimating];
    
    [enemies addObject:enemy];
    [UIView animateWithDuration: speed
                          delay: 0.0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         [enemy setFrame:CGRectMake(enemy.frame.origin.x, self.view.frame.size.height + 100, enemy.frame.size.width, enemy.frame.size.height)];
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
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(shootLaser:) userInfo:nil repeats:YES];
    
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
    [UIView animateWithDuration:player.frame.origin.y/500
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
            if(CGRectContainsPoint(CGRectMake(enemy.layer.presentationLayer.frame.origin.x + 35,
                                              enemy.layer.presentationLayer.frame.origin.y + 65,
                                              25,
                                              25),
                                   CGPointMake(laser.layer.presentationLayer.frame.origin.x + 40,
                                               laser.layer.presentationLayer.frame.origin.y + 40))) {
                                       [enemy.layer removeAllAnimations];
                                       [laser.layer removeAllAnimations];
                                       int current = scoreLabel.text.intValue;
                                       current++;
                                       scoreLabel.text = [NSString stringWithFormat:@"%d", (int)current];
                                       UIImageView * explosion = [[UIImageView alloc] initWithFrame:CGRectMake(enemy.layer.presentationLayer.frame.origin.x-50, enemy.layer.presentationLayer.frame.origin.y, 200, 200)];
                                       explosion.animationImages = [NSArray arrayWithObjects:
                                                                    [UIImage imageNamed:@"explosion0"],
                                                                    [UIImage imageNamed:@"explosion1"],
                                                                    [UIImage imageNamed:@"explosion2"], nil];
                                       explosion.animationDuration = 0.3f;
                                       [explosion setAnimationRepeatCount:1];
                                       [self.view addSubview:explosion];
                                       [explosion startAnimating];
                                   }
        }
        if(CGRectContainsRect(player.layer.presentationLayer.frame, CGRectMake(enemy.layer.presentationLayer.frame.origin.x + 10,
                                                                               enemy.layer.presentationLayer.frame.origin.y + 10,
                                                                               50,
                                                                               50))) {
            [self playerHit];
        }
    }
}

- (void)playerHit {
    exit(0);
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
    [self.view sendSubviewToBack: bgView1];
    [self.view sendSubviewToBack: bgView2];
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
