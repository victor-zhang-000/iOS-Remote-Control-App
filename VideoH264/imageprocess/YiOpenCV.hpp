/*****************************************************************************
 *   YiOpenCV.hpp
 *****************************************************************************/

#pragma once

#import "opencv2/core/core.hpp"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/*
@interface YiOpenCV : NSObject

void colorDetect(const cv::Mat& frame, cv::Mat& retroFrame);

- (void) colorDetect: (UIImage *) inputImage ReturnImage: (int) isReturn;

@end
*/

class YiOpenCV
{
public:
    struct Parameters
    {
        cv::Size frameSize;
    };
    
    //YiOpenCV(const Parameters& params);
    CGFloat posX;
    CGFloat posY;
    YiOpenCV() {posX=0;posY=0;}
    void colorDetect(const cv::Mat& frame, cv::Mat& retroFrame);
    void objectFinder(cv::Mat procc);
    CGFloat getPositionx();
    CGFloat getPositiony();

    
protected:
    Parameters params_;
    };
