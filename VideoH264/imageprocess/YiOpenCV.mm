/*****************************************************************************
 *   YiOpenCV.mm
 *****************************************************************************/

#include "YiOpenCV.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/highgui/highgui.hpp"
#import "opencv2/opencv.hpp"



using namespace cv;



CGFloat YiOpenCV::getPositionx(){
    return posX;
}

CGFloat YiOpenCV::getPositiony(){
    return posY;
}

void YiOpenCV::colorDetect(const Mat& frame, Mat& retroFrame)
{

    Mat imgHSV;
    vector<Mat> hsvSplit;
    cvtColor(frame, imgHSV, COLOR_BGR2HSV); //Convert the captured frame from BGR to HSV
    
    IplImage temp2;
    IplImage *openCVImage = cvCreateImage(frame.size(), IPL_DEPTH_8U, 3);
    
    temp2 = IplImage(frame);

    cvCvtColor(&temp2, openCVImage, CV_BGR2RGB);//CV_BGR2HSV_FULL);
    
    IplImage *colourImage = cvCreateImage(frame.size(), IPL_DEPTH_8U, 3);
    cvCvtColor(&temp2, colourImage, CV_BGR2HSV_FULL);
    IplImage *imgGreen=cvCreateImage(cvGetSize(openCVImage),IPL_DEPTH_8U, 1);
    IplImage *imgRed=cvCreateImage(cvGetSize(openCVImage),IPL_DEPTH_8U, 1);
    //IplImage *imgDarkRed=cvCreateImage(cvGetSize(openCVImage),IPL_DEPTH_8U, 1);
    IplImage *imgBlue=cvCreateImage(cvGetSize(openCVImage),IPL_DEPTH_8U, 1);
    IplImage *imgYel=cvCreateImage(cvGetSize(openCVImage),IPL_DEPTH_8U, 1);
    
    cvInRangeS(colourImage, cvScalar(160, 100, 100), cvScalar(180, 255, 255),imgRed);
    cvInRangeS(colourImage, cvScalar(40, 100, 30), cvScalar(80, 255, 255),imgGreen);
    cvInRangeS(colourImage, cvScalar(0, 50, 50), cvScalar(50, 255, 255),imgBlue);
    cvInRangeS(colourImage, cvScalar(130, 100, 100), cvScalar(140, 255, 255),imgYel);
    
    int redCount=cv::countNonZero(cv::Mat(imgRed)) ;
    int blueCount=cv::countNonZero(cv::Mat(imgBlue)) ;
    int greenCount=cv::countNonZero(cv::Mat(imgGreen)) ;
    int yelCount=cv::countNonZero(cv::Mat(imgYel));
    
    cv::addWeighted(cv::Mat(imgGreen), 1, cv::Mat(imgRed), 1, 0, cv::Mat(imgRed));
    cv::addWeighted(cv::Mat(imgBlue), 1, cv::Mat(imgRed), 1, 0, cv::Mat(imgRed));
    
    cv::Mat final =cv::Mat(imgRed);
    retroFrame=final;
    objectFinder(final);
    
    cvReleaseImage(&openCVImage);
    cvReleaseImage(&colourImage);
    cvReleaseImage(&imgGreen);
    cvReleaseImage(&imgBlue);
    cvReleaseImage(&imgYel);
    
}


void YiOpenCV::objectFinder(Mat procc){
    
    cv::Mat threshold_output;
    cv::vector<cv::vector<cv::Point> > contours;
    cv::vector<cv::Vec4i> hierarchy;
    cv::vector<cv::Point> approx;
    int cnt = 0;

    cv::Canny( procc, procc, 100, 300, 3 );
    
    cv::findContours(procc, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0));
    
    for( int i = 0; i < contours.size(); i++ ){
        
        double eps = contours[i].size() * 0.05;
        cv::Moments mom;
        cv::Mat contour = cv::Mat(contours[i]);
        cv::approxPolyDP(contour, approx, eps, true);
        
        
        // Skip small or non-convex objects
        if (std::fabs(cv::contourArea(contours[i])) < 100 || !cv::isContourConvex(approx))
            continue;
        
        if (approx.size() == 3){
            
            mom= cv::moments(cv::Mat(contours[i]));
            // draw mass center
            
            cv::Point2f pot = cv::Point(mom.m10/mom.m00,mom.m01/mom.m00);
            
            NSLog(@"TRI %f, %f, %f",pot.x, pot.y, cv::contourArea(contours[i]));
            posX= (CGFloat)pot.x;
            posY= (CGFloat)pot.y;
        }
    }
    
}
