//
//  YiAnimation.h
//  H264UseStream
//
//  Created by 张 溢 on 17/4/1.
//  Copyright © 2017年 evenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface YiAnimation : NSObject

-(void)missle: (CALayer*)layer topoint: (CGPoint)point;
-(int)updatemissleframes: (CALayer*)layer;
-(void)explode: (CALayer*)layer atpoint: (CGPoint)point;
-(int) updateexplodeframes: (CALayer*)layer;
//-(void)beingHit:

@end
