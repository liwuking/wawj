//
//  CircularView.m
//  wawj
//
//  Created by ruiyou on 2017/10/18.
//  Copyright © 2017年 technology. All rights reserved.
//

#import "CircularView.h"

@implementation CircularView
{
    NSTimer *_timer;
    NSInteger _timeLength;
    NSInteger _timeLengthed;
    float _progress;
    
}
-(void)startCircleWithTimeLength:(NSInteger)timeLength {
    
    _timeLengthed = 0;
    _timeLength = timeLength;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeUp) userInfo:nil repeats:YES];
    [self.delegate circularViewStartDraw];
}

-(void)timeUp {
    
    _timeLengthed = _timeLengthed+1;
    
    _progress = (float)_timeLengthed/_timeLength;
    if (_progress <= 1) {
        [self setNeedsDisplay];
        [self.delegate circularViewWithProgress:_timeLengthed];
    } else {
        _progress = 0;
        [self setNeedsDisplay];
        [self.delegate circularViewEndDraw];
        [_timer invalidate];
        _timer = nil;
    }

    
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();//获取上下文
    
    CGPoint center = CGPointMake(75, 75);  //设置圆心位置
    CGFloat radius = 75;  //设置半径
    CGFloat startA = - M_PI_2;  //圆起点位置
    CGFloat endA = -M_PI_2 + M_PI * 2 * _progress;  //圆终点位置
    NSLog(@"_progress: %f", _progress);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startA endAngle:endA clockwise:YES];
    
    CGContextSetLineWidth(ctx, 10); //设置线条宽度
    [HEX_COLOR(0x79C6ED) setStroke]; //设置描边颜色
    
    CGContextAddPath(ctx, path.CGPath); //把路径添加到上下文
    
    CGContextStrokePath(ctx);  //渲染
    
}


-(void)stopCircle {
    if (_timer) {
        _timer.fireDate = [NSDate distantFuture];
    }
    
}

-(void)startCircle {
    
    if (_timer) {
        _timer.fireDate = [NSDate date];
    }
}


-(void)endCircle {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _progress = 0;
    [self setNeedsDisplay];
    
    
    
}
-(void)dealloc {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
