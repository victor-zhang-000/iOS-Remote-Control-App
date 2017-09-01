//
//  ImageProcess.h
//  H264UseStream
//
//  Created by 张 溢 on 17/3/4.
//  Copyright © 2017年 evenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface ImageProcess : NSObject

- (UIImage*)applyEffect:(UIImage*)image;
- (CGPoint)getPoint;

@property(nonatomic) CGPoint pointA;

@end
