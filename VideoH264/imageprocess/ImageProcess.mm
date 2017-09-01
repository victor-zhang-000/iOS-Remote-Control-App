//
//  ImageProcess.m
//  H264UseStream
//
//  Created by 张 溢 on 17/3/4.
//  Copyright © 2017年 evenCoder. All rights reserved.
//

#import "ImageProcess.h"
#import "YiOpenCV.hpp"
#import "UIImage+OpenCV.hpp"

@implementation ImageProcess

@synthesize pointA;

- (UIImage*)applyEffect:(UIImage*)image{
    
    cv::Mat frame= [UIImage cvMatFromUIImage:image];

    YiOpenCV yiOpenCV;
    
    cv::Mat finalFrame;
    yiOpenCV.colorDetect(frame, finalFrame);
    //NSLog(@"Calllll");
    
    UIImage* result =[UIImage imageWithCVMat:finalFrame];
    CGFloat posX=yiOpenCV.getPositionx();
    CGFloat posY=yiOpenCV.getPositiony();
    //CGPoint pointA;
    pointA.x=posX;
    pointA.y=posY;
    
    frame.release();
    finalFrame.release();
    return result;
    
}

- (CGPoint)getPoint{
    NSLog(@"get point: %f,%f",pointA.x,pointA.y);
    return pointA;
}


@end
