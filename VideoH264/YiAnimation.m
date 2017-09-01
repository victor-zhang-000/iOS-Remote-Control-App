//
//  YiAnimation.m
//  H264UseStream
//
//  Created by 张 溢 on 17/4/1.
//  Copyright © 2017年 evenCoder. All rights reserved.
//

#import "YiAnimation.h"

//#import <VideoToolbox/VideoToolbox.h>


#define IMAGE_COUNT_MISSLE 16
#define IMAGE_COUNT_EXPLODE 13

@interface YiAnimation()
{
    NSMutableArray *_missleimages;
    int _missleindex;
    int countmissle;
    
    NSMutableArray *_explodeimages;
    int _explodeindex;
    int countexplode;

}

@end


@implementation YiAnimation

-(void)missle: (CALayer*)layer topoint: (CGPoint)point
{
    countmissle=0;
    
    //assign missile images to array
    _missleimages = [NSMutableArray array];
    for (int i = 0; i < 16; i++) {
        NSString *imageName = [NSString stringWithFormat:@"missle%i.png", i];
        UIImage *image = [UIImage imageNamed:imageName];
        [_missleimages addObject:image];
    }
    
    //edit animation path
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 450, 185); //start point
    CGPathAddLineToPoint(path,NULL, point.x, point.y); //destination point
    animation.path = path;
    
    animation.repeatCount = 1;
    animation.duration = 1;
    animation.removedOnCompletion = YES;
    
    [layer addAnimation:animation forKey:@"Animation"];
    
    CGPathRelease(path);
}

-(int) updatemissleframes: (CALayer*)layer
{
    countmissle+=1;
    UIImage *image = _missleimages[_missleindex];
    layer.contents = (id)image.CGImage;
    _missleindex = (_missleindex + 1) % IMAGE_COUNT_MISSLE;
    
    return countmissle;
}


-(void)explode: (CALayer*)layer atpoint: (CGPoint)point
{
    countexplode=0;
    _explodeimages = [NSMutableArray array];
    for (int i = 0; i < 13; i++) {
        NSString *imageName = [NSString stringWithFormat:@"explode%i.png", i];
        UIImage *image = [UIImage imageNamed:imageName];
        [_explodeimages addObject:image];
    }
    
    layer.position=point;

}


-(int) updateexplodeframes: (CALayer*)layer
{
    countexplode+=1;
    //if(countexplode<40)
        //return 0;
    UIImage *image = _explodeimages[_explodeindex];
    layer.contents = (id)image.CGImage;
    _explodeindex = (_explodeindex + 1) % IMAGE_COUNT_EXPLODE;
    return countexplode;
    
}



@end
