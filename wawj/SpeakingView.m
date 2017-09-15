//
//  SpeakingView.m
//  AFanJia
//
//  Created by 焦庆峰 on 2016/12/2.
//  Copyright © 2016年 焦庆峰. All rights reserved.
//

#import "SpeakingView.h"

@implementation SpeakingView
//@synthesize delegate;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    _bgView.layer.cornerRadius = 5;
}

- (void)startAction {
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.45 target:self selector:@selector(changeVolumeImage) userInfo:nil repeats:YES];
    
}
- (void)changeVolumeImage {
    NSString *imageNamed = [NSString stringWithFormat:@"RecordingSignal00%d.png",[self getRandomNumber:3 to:8]];
    NSLog(@"imageNamed = %@",imageNamed);
    _volumeImageView.image = [UIImage imageNamed:imageNamed];
}
-(int)getRandomNumber:(int)from to:(int)to
{
    return (int)(from + (arc4random() % (to - from + 1)));
}


- (void)endSpeak {
    [_timer invalidate];
    [self removeFromSuperview];
}
- (void)cannelSpeak {
    [_timer invalidate];
    [self removeFromSuperview];
}

@end
