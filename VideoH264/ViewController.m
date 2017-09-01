//
//  ViewController.m
//  VideoH264
//
//  Created by 张 溢 on 17/1/20.
//  Copyright © 2017年 yizhang. All rights reserved.
//


#import "ViewController.h"
#import "YiOpenGLView.h"
#import <VideoToolbox/VideoToolbox.h>
#import "ImageProcess.h"
#import "YiAnimation.h"


#define SCREENWIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGH  [UIScreen mainScreen].bounds.size.height
#define buttonWH 50


@interface ViewController() {
    
    dispatch_queue_t          jDecodeQueue;
    VTDecompressionSessionRef jDecodeSession; // 解码
    CMFormatDescriptionRef    jFormatDescription;
    uint8_t                   *jSPS;
    long                      jSPSSize;
    uint8_t                   *jPPS;
    long                      jPPSSize;
    
    // 输入
    NSInputStream             *jInputStream; // 用NSInputStream读入原始H.264码流
    uint8_t                   *jPacketBuffer;
    long                      jPacketSize;
    uint8_t                   *jInputBuffer;
    long                      jInputSize;
    long                      jInputMaxSize;
    
    CFReadStreamRef  readStream;
    CFWriteStreamRef writeStream;
    CFReadStreamRef  readStream2;
    CFWriteStreamRef writeStream2;
    
    ImageProcess *imageProcess;
    UIImage *displayImage;


    long countN;
    int countM;
    
    int isLanding;
    int positionID;
    int returnID;
    int returnvalue;
    
    int hp1;
    int hp2;
    
    CALayer *layerexplode;
    CALayer *layermissle;
    CALayer *gameOver;
    YiAnimation *animation1;
    
    
}

@property (nonatomic, strong) YiOpenGLView *jOpenGLView;


@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UIButton *messageButton;
@property (nonatomic, strong) UIButton *missleButton;

@property (nonatomic, strong) CADisplayLink *jDisplayLink;

@property (nonatomic, strong) UIImageView *targetView;

@property(nonatomic,strong) UIProgressView *lifeValue1;
@property(nonatomic,strong) UIProgressView *lifeValue2;

@property(nonatomic,strong) UILabel *lifeLabel1;
@property(nonatomic,strong) UILabel *lifeLabel2;


@end

const uint8_t lyStartCode[4] = {0, 0, 0, 1};
const uint8_t lyStartCode2[3] = {0, 0, 1};


@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    isLanding=0;
    positionID=0;
    returnvalue=0;
    returnID=0;
    hp1=100;
    hp2=100;
    
    [self initJoyStick];
    
    self.jOpenGLView = [[YiOpenGLView alloc] init];
    self.jOpenGLView.frame = self.view.bounds;
    [self.view addSubview:self.jOpenGLView];
    [self.view sendSubviewToBack:self.jOpenGLView];
    [self.jOpenGLView setupGL];
    
        
    jDecodeQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    [self setupLabelAndButton];
    
    // 用CADisplayLink 控制显示速率
    self.jDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateFrame)];
    [self.jDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode]; // 添加RunLoop
    [self.jDisplayLink setPaused:YES];
    
    
    imageProcess = [[ImageProcess alloc] init];
    [self initPositionTimer];
    [self initAnimation];
    
}

- (IBAction)test:(id)sender {
    [self beingHit];
}

- (IBAction)goBack:(id)sender {
    [self performSegueWithIdentifier:@"goBack1" sender:self];
}

- (void)initNetworkCommunication {
    
    
    NSString *planeAddress;
    if(_plane==1)
        planeAddress = @"172.20.10.6";
    else
        planeAddress = @"172.20.10.9";

    
        @try{
            CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)planeAddress, 54321, &readStream, &writeStream);
            CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)planeAddress, 55555, &readStream2, &writeStream2);
        }
        
        @catch(NSException *exception){
            NSLog(@"network connection fail");
            return;
        }
        
        @finally{}
    
    
    //CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)planeAddress, 54321, &readStream, &writeStream);
    //CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)planeAddress, 55555, &readStream2, &writeStream2);

    
    
    
    self.inputStream = (__bridge NSInputStream *)readStream;
    self.outputStream = (__bridge NSOutputStream *)writeStream;
    
    self.inputStream2 = (__bridge NSInputStream *)readStream2;
    self.outputStream2 = (__bridge NSOutputStream *)writeStream2;
    
    
    
    [_inputStream2 open];
    [_outputStream2 open];
    
    [_inputStream2 setDelegate:self];
    [_outputStream2 setDelegate:self];
    
    [_inputStream2 scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream2 scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

    
    if(_gameMode==2){
    _socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *err = nil;
        _socket.delegate=self;
    [_socket connectToHost:@"172.20.10.10" onPort:[@"52222" intValue] error:&err];
    }

    [_socket readDataWithTimeout:-1 tag:0];

    
    //[_socket writeData:[[NSString stringWithFormat:@"666"] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];

}

- (void)initJoyStick{
    _JoyStickLeft.mode=LEFT;
    _JoyStickRight.mode=RIGHT;
}


- (void)initAnimation{
    animation1= [[YiAnimation alloc] init];
    layermissle = [[CALayer alloc] init];
    layermissle.bounds = CGRectMake(0, 0, 80, 56);
    //_layer.position = CGPointMake(self.view.center.x, self.view.center.y);
    layermissle.position = CGPointMake(0, 0);
    [self.view.layer addSublayer:layermissle];
    
    layerexplode = [[CALayer alloc] init];
    layerexplode.bounds = CGRectMake(0, 0, 100, 100);
    layerexplode.position = CGPointMake(0, 0);
    [self.view.layer addSublayer:layerexplode];

}

- (void)initPositionTimer{
    NSDate *scheduledTime = [NSDate dateWithTimeIntervalSinceNow:1.0];
    NSString *customUserObject = @"To demo userInfo";
    NSTimer *timer = [[NSTimer alloc] initWithFireDate:scheduledTime
                                              interval:0.05
                                                target:self
                                              selector:@selector(getStickPosition)
                                              userInfo:customUserObject
                                               repeats:YES];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
    
}



- (void)setupLabelAndButton {
    
    self.startButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREENWIDTH - buttonWH) * 0.5, buttonWH * 2, buttonWH, buttonWH)];
    self.startButton.layer.cornerRadius = buttonWH * 0.5;
    self.startButton.layer.masksToBounds = YES;
    [self.startButton setImage:[UIImage imageNamed:@"logo_3745aaf"] forState:UIControlStateNormal];
    [self.startButton addTarget:self action:@selector(centerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.startButton];
    
    self.messageButton = [[UIButton alloc] initWithFrame:CGRectMake(70, 300, buttonWH, buttonWH)];
    self.messageButton.layer.cornerRadius = buttonWH * 0.5;
    self.messageButton.layer.masksToBounds = YES;
    [self.messageButton setImage:[UIImage imageNamed:@"landing.png"] forState:UIControlStateNormal];
    [self.messageButton addTarget:self action:@selector(messageBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.messageButton];
    
    self.missleButton = [[UIButton alloc] initWithFrame:CGRectMake(580, 300, buttonWH, buttonWH)];
    //self.missleButton.layer.cornerRadius = buttonWH * 0.5;
    self.missleButton.layer.masksToBounds = YES;
    [self.missleButton setImage:[UIImage imageNamed:@"missileBtn.png"] forState:UIControlStateNormal];
    [self.missleButton addTarget:self action:@selector(missleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.missleButton];
    
    
    self.lifeValue1=[[UIProgressView alloc] initWithFrame:CGRectMake(280, 295, 100, 20)];
    self.lifeValue1.transform=CGAffineTransformMakeRotation(M_PI*3/2);
    self.lifeValue1.progress=1;
    self.lifeValue1.progressTintColor=[UIColor greenColor];
    [self.view addSubview:self.lifeValue1];
    
    self.lifeValue2=[[UIProgressView alloc] initWithFrame:CGRectMake(295, 295, 100, 20)];
    self.lifeValue2.transform=CGAffineTransformMakeRotation(M_PI*3/2);
    self.lifeValue2.progress=1;
    self.lifeValue2.progressTintColor=[UIColor redColor];
    [self.view addSubview:self.lifeValue2];
    
    self.lifeLabel1=[[UILabel alloc] initWithFrame:CGRectMake(285, 195, 32, 20)];
    self.lifeLabel1.textColor = [UIColor greenColor];
    self.lifeLabel1.layer.cornerRadius = 7;
    self.lifeLabel1.layer.masksToBounds = YES;
    self.lifeLabel1.backgroundColor=[UIColor blackColor];
    self.lifeLabel1.text = [NSString stringWithFormat:@"%d",hp1];
    [self.view addSubview:self.lifeLabel1];
    
    
    self.lifeLabel2=[[UILabel alloc] initWithFrame:CGRectMake(340, 195, 32, 20)];
    self.lifeLabel2.textColor = [UIColor redColor];
    self.lifeLabel2.layer.cornerRadius = 7;
    self.lifeLabel2.layer.masksToBounds = YES;
    self.lifeLabel2.backgroundColor=[UIColor blackColor];
    self.lifeLabel2.text = [NSString stringWithFormat:@"%d",hp2];
    [self.view addSubview:self.lifeLabel2];
}

- (int)roundPosition: (int) x{
    if(x==64) x=63;
    if(x==-64) x=-63;
    return x;
}

- (void)getStickPosition{
    int x=_JoyStickLeft.xValue;
    int y=_JoyStickLeft.yValue;
    int x2=_JoyStickRight.xValue;
    int y2=_JoyStickRight.yValue;
    x=[self roundPosition:x];
    y=[self roundPosition:y];
    x2=[self roundPosition:x2];
    y2=[self roundPosition:y2];
    
   
    if (returnvalue==101){
        NSLog(@"hit");
        [self beingHit];
    }
    
    //update life value
    self.lifeLabel1.text = [NSString stringWithFormat:@"%d",hp1];
    
    if (hp1>=0) self.lifeValue1.progress= hp1/100.0;
    self.lifeLabel2.text = [NSString stringWithFormat:@"%d",hp2];
    if (hp2>=0) self.lifeValue2.progress= hp2/100.0;

    
    if ((hp1<=0)||(hp2<=0))
    {
        [self gameOver];
    }
    
    //give an ID to each string from 1 to 100
    //NSLog(@"P:%d,R: %d",positionID,returnID);
    
    if(returnID<positionID)
        return;
    else
    {
        positionID++;
        positionID=positionID%100;
        static int misslecount=0;
        
        if (misslecount>=1){
            isLanding=0;
            misslecount=0;
        }
        
        if(isLanding==2) //launch missile
            misslecount+=1;
        
        NSString *position1= [NSString stringWithFormat:@"%d,%d,%d,%d,%d,%d",positionID,x,y,x2,y2,isLanding];
        NSData *data = [[NSData alloc] initWithData:[position1 dataUsingEncoding:NSASCIIStringEncoding]];
        [_outputStream2 write:[data bytes] maxLength:[data length]];
        /*
        int pNow=positionID;
        double delayInSeconds = 1;
        
        dispatch_time_t poptime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        
        dispatch_after(poptime, dispatch_get_main_queue(), ^{
            if (pNow==positionID)
                positionID++;
        });

        */
        NSLog(position1);

    }
    
}



#pragma mark - 开始解码

/**
 *  开始视频解码
 */
- (void)startDecode {
    
    [self videoStart];
    [self.jDisplayLink setPaused:NO];
}

#pragma mark - 获取H.264
- (void)videoStart {
    
    //NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"test.h264"];
    // 用NSInputStream读入原始H.264码流
    //jInputStream = [[NSInputStream alloc] initWithFileAtPath:filePath];
    //[jInputStream open];
    
    jInputSize = 0;
    jInputMaxSize = SCREENHEIGH * SCREENWIDTH * 3 * 4 ;
    jInputBuffer = malloc(jInputMaxSize); // malloc 向系统申请分配指定size个字节的内存空间
}

#pragma mark - 停止解码
- (void)onInputEnd {
    
    [jInputStream close];
    jInputStream = nil;
    if (jInputBuffer) {
        
        free(jInputBuffer);
        jInputBuffer = NULL;
    }
    [self.jDisplayLink setPaused:YES];
    [self endVideoToolBox];
    self.startButton.hidden = NO;
}

#pragma mark - <RunLoop selector>不断刷新frame
- (void)updateFrame {
    //NSLog(@"updateFrame");
    
    self.inputStream = (__bridge NSInputStream *)readStream;
    self.outputStream = (__bridge NSOutputStream *)writeStream;
    
    [_inputStream open];
    [_outputStream open];
    
    if (_inputStream) {
        
        dispatch_sync(jDecodeQueue, ^{
            
            [self readPacket];
            
            if (jPacketBuffer == NULL){
                return;
            }
            countN+=1;
            
            // replace header
            uint32_t nalSize = (uint32_t)(jPacketSize - 4);
            uint32_t *pNalSize = (uint32_t *)jPacketBuffer;
            *pNalSize = CFSwapInt32BigToHost(nalSize);
            
            
            // detect frame types: SPS/PPS
            CVPixelBufferRef pixelBuffer = NULL;
            int nalType = jPacketBuffer[4] & 0x1F;
            
            switch (nalType) {
                case 0x05:
                    //NSLog(@"Nal type is IDR frame"); // read I frame, start decoding
                    [self initVideoToolBox];
                    pixelBuffer = [self decode];
                    break;
                case 0x07:
                    //NSLog(@"Nal type is SPS");
                    jSPSSize = jPacketSize - 4;
                    jSPS = malloc(jSPSSize);
                    memcpy(jSPS, jPacketBuffer + 4, jSPSSize); // move packet to buffer
                    break;
                case 0x08:
                    //NSLog(@"Nal type is PPS");
                    jPPSSize = jPacketSize - 4;
                    jPPS = malloc(jPPSSize);
                    memcpy(jPPS, jPacketBuffer + 4, jPPSSize); // move packet to buffer
                    break;
                default:
                    //NSLog(@"Nal type is B/P frame");
                    pixelBuffer = [self decode];
                    break;
            }
            
            
            if (pixelBuffer) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // 显示解码的结果
                    // 解码得到的CVPixelBufferRef会传入OpenGL ES类进行解析渲染。
                    //[self.jOpenGLView displayPixelBuffer:pixelBuffer];
                    
                    displayImage=[self.jOpenGLView displayPixelBuffer:pixelBuffer];
                    
                    CVPixelBufferRelease(pixelBuffer);
                    
                    
                    if ([animation1 updatemissleframes:layermissle]==38)
                        layermissle.hidden=YES;
                    
                    int explodecount=[animation1 updateexplodeframes:layerexplode];
                    
                    if (explodecount<40)
                        layerexplode.hidden=YES;
                    else if(explodecount>58) //after explosion
                    {
                        layerexplode.hidden=YES;
                        if(_targetView!=nil)
                        {
                            [self.targetView removeFromSuperview];
                            self.targetView.hidden=YES;
                        }
                    }
                    else
                    {
                        layerexplode.hidden=NO;
                        layermissle.hidden=YES;
                    }
                    
                });
            }
            //NSLog(@"Read Nalu size %ld", jPacketSize);
            //NSLog(@"jInputSize %ld", jInputSize);
        });
    }
}

#pragma mark - Game Actions


- (void)centerBtnClick:(UIButton *)sender {
    
    [self initNetworkCommunication];
    
    [_inputStream open];
    [_outputStream open];
    
    self.startButton.hidden = YES;
    [self startDecode];
}

- (void)missleBtnClick:(UIButton *)sender {
    
    [self processImage];
    isLanding=2;
    
    /*
    double delayInSeconds = 0.5;
    
    dispatch_time_t poptime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    dispatch_after(poptime, dispatch_get_main_queue(), ^{
        if(hp2>=10) hp2-=10;
    });
     
    */
    
}

- (void)messageBtnClick:(UIButton *)sender {
    isLanding =1; //auto landing
    
}

- (void)beingHit
{
    if(hp1>=10) hp1-=10;
    self.jOpenGLView.alpha=0.3;
    double delayInSeconds = 0.5;
    
    dispatch_time_t poptime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    dispatch_after(poptime, dispatch_get_main_queue(), ^{
        self.jOpenGLView.alpha=1;
    });
    
    //perform animation.
}

- (void)gameOver
{
    gameOver = [[CALayer alloc] init];
    gameOver.bounds = CGRectMake(0, 0, 350, 160);
    gameOver.position = CGPointMake(320, 120);
    
    //NSString *imageName = [NSString stringWithFormat:@"win.png"];
    UIImage *win = [UIImage imageNamed:[NSString stringWithFormat:@"win.png"]];
    UIImage *lose = [UIImage imageNamed:[NSString stringWithFormat:@"lose.png"]];
   
    
    if (hp1<=0)
        gameOver.contents = (id)lose.CGImage;
    if (hp2<=0)
        gameOver.contents = (id)win.CGImage;
    
    [self.view.layer addSublayer:gameOver];
}

- (void)processImage{
    
    //self.iView.image=[imageProcess applyEffect:displayImage];
    //NSLog(@"process image");
    
    [imageProcess applyEffect:displayImage];
    
    
    UIImage * logo=[UIImage imageNamed:@"SquareTarget.png"];
    //int width = logo.size.width*0.5;
    //int height = logo.size.height*0.5;
    int width=100;
    int height=100;
    CGPoint targetpoint=imageProcess.getPoint;
    CGFloat xPos=targetpoint.x;
    CGFloat yPos=targetpoint.y;
    //if(_targetView!=nil)
        //[self.targetView removeFromSuperview];
    /*
    xPos=333;
    yPos=100;
    targetpoint.x=xPos;
    targetpoint.y=yPos;
     */
    
    if((xPos!=0)&&(yPos!=0))
        _targetView = [[UIImageView alloc] initWithFrame:CGRectMake(xPos-width/2, yPos-height/2, width, height)];
    [_targetView setImage:logo];
    [_targetView setAlpha:0.8];
    [self.view addSubview:self.targetView];
    [self.view bringSubviewToFront:_targetView];
    self.targetView.hidden=NO;
    
    if((xPos!=0)&&(yPos!=0))
    {
        layermissle.hidden=NO;
        //layerexplode.hidden=NO;
        [animation1 missle:layermissle topoint:targetpoint];
        [animation1 explode:layerexplode atpoint:targetpoint];
    }
    //UIImage * processedImage=[imageProcess applyEffect:displayImage];
    //[imageProcss applyEffect:displayImage];
    
}


/*
- (NSString *)hexStringFromString:(NSString *)string{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    return myD;
}
*/

#pragma mark - 获取前四个字节识别SPS和PPS并存储到缓存中

- (void)readPacket {
    if (jPacketSize && jPacketBuffer) {
        
        jPacketSize = 0;
        free(jPacketBuffer);
        jPacketBuffer = NULL;
    }
    
    if (jInputSize < jInputMaxSize && _inputStream.hasBytesAvailable) {//replace
        //get video length
        jInputSize += [_inputStream read:jInputBuffer + jInputSize maxLength:jInputMaxSize - jInputSize];
    }
    if (memcmp(jInputBuffer, lyStartCode, 4) == 0) {
        // get video content
        if (jInputSize > 4) {
            uint8_t *pStart = jInputBuffer + 4;
            uint8_t *pEnd = jInputBuffer + jInputSize;
            while (pStart != pEnd) { //find the next 0x00000001
                if(*pStart == 0x01)
                {
                    if(memcmp(pStart - 3, lyStartCode, 4) == 0) {
                        jPacketSize = pStart - jInputBuffer - 3;
                        if (jPacketBuffer) {
                            free(jPacketBuffer);
                            jPacketBuffer = NULL;
                        }
                        jPacketBuffer = malloc(jPacketSize);
                        memcpy(jPacketBuffer, jInputBuffer, jPacketSize); // move packet to buffer
                        memmove(jInputBuffer, jInputBuffer + jPacketSize, jInputSize - jPacketSize);
                        // move the buffer
                        jInputSize -= jPacketSize;
                        return;
                    }
                }
                ++pStart;
            }
            if (jPacketBuffer) {
                free(jPacketBuffer);
                jPacketBuffer = NULL;
            }
        }
    }
    
}


/*
 else if(memcmp(pStart - 2, lyStartCode2, 3) == 0) {
 NSLog(@"hello4");
 jPacketSize = pStart - jInputBuffer - 2;
 
 if (jPacketBuffer) {
 free(jPacketBuffer);
 jPacketBuffer = NULL;
 }
 
 jPacketBuffer = malloc(jPacketSize);
 memcpy(jPacketBuffer, jInputBuffer, jPacketSize); // 复制packet内容到新的缓冲区
 memmove(jInputBuffer, jInputBuffer + jPacketSize, jInputSize - jPacketSize); // 把缓冲区前移
 jInputSize -= jPacketSize;
 return;//break;
 }
 */

#pragma mark - 初始化VideoToolBox

- (void)initVideoToolBox {
    
    if (!jDecodeSession) {
        
        // SPS+PPS to CMVideoFormatDescription
        const uint8_t *parameterSetPointers[2] = {jSPS, jPPS};
        const size_t parameterSetSizes[2] = {jSPSSize, jPPSSize};
        OSStatus status = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault,
                                                                              2, // param count
                                                                              parameterSetPointers,
                                                                              parameterSetSizes,
                                                                              4, // nal start code size
                                                                              &jFormatDescription);
        if (status == noErr) {
            
            CFDictionaryRef dictRef = NULL;
            const void *keys[] = {kCVPixelBufferPixelFormatTypeKey};
            //      kCVPixelFormatType_420YpCbCr8Planar is YUV420
            //      kCVPixelFormatType_420YpCbCr8BiPlanarFullRange is NV12
            uint32_t key = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
            const void *values[] = {CFNumberCreate(NULL, kCFNumberSInt32Type, &key)};
            dictRef = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
            
            VTDecompressionOutputCallbackRecord callBackRecord;
            callBackRecord.decompressionOutputCallback = didDecompress;
            callBackRecord.decompressionOutputRefCon = NULL;
            
            status = VTDecompressionSessionCreate(kCFAllocatorDefault, jFormatDescription, NULL, dictRef, &callBackRecord, &jDecodeSession);
            
            CFRelease(dictRef);
        }
        else {
            
            NSLog(@"IOS8VT: reset decoder session failed status =% d", status);
        }
    }
}

#pragma mark - 结束播放
- (void)endVideoToolBox {
    
    if (jDecodeSession) {
        
        VTDecompressionSessionInvalidate(jDecodeSession);
        CFRelease(jDecodeSession);
        jDecodeSession = NULL;
    }
    if (jFormatDescription) {
        
        CFRelease(jFormatDescription);
        jFormatDescription = NULL;
    }
    free(jSPS);
    free(jPPS);
}

#pragma mark - 开始解码

- (CVPixelBufferRef)decode {
    
    CVPixelBufferRef outputPixelBuffer = NULL;
    if (jDecodeSession) {
        
        //  NALUnit -> CMBlockBuffer
        CMBlockBufferRef blockBuffer = NULL;
        OSStatus status = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault, (void *)jPacketBuffer, jPacketSize, kCFAllocatorNull, NULL, 0, jPacketSize, 0, &blockBuffer);
        if (status == kCMBlockBufferNoErr) {
            
            // to CMSampleBuffer
            CMSampleBufferRef sampleBuffer = NULL;
            const size_t sampleSizeArray[] = {jPacketSize};
            status = CMSampleBufferCreateReady(kCFAllocatorDefault, blockBuffer, jFormatDescription, 1, 0, NULL, 1, sampleSizeArray, &sampleBuffer);
            
            
            if (status == kCMBlockBufferNoErr && sampleBuffer) {
                
                VTDecodeFrameFlags flags = 0;
                VTDecodeInfoFlags  infoFlags = 0;
                // outputPixelBuffer start decoding
                OSStatus decodeStatus = VTDecompressionSessionDecodeFrame(jDecodeSession, sampleBuffer, flags, &outputPixelBuffer, &infoFlags);
                
                if(decodeStatus == kVTInvalidSessionErr) {
                    NSLog(@"IOS8VT: Invalid session, reset decoder session");
                } else if(decodeStatus == kVTVideoDecoderBadDataErr) {
                    NSLog(@"IOS8VT: decode failed status=%d(Bad data)", decodeStatus);
                } else if(decodeStatus != noErr) {
                    NSLog(@"IOS8VT: decode failed status=%d", decodeStatus);
                }
                CFRelease(sampleBuffer);
            }
            CFRelease(blockBuffer);
        }
    }
    return outputPixelBuffer;
}

#pragma mark - 解码完成回调 回调didDecompress
void didDecompress(void *decompressionOutputRefCon, void *sourceFrameRefCon, OSStatus status, VTDecodeInfoFlags infoFlags, CVImageBufferRef pixelBuffer, CMTime presentationTimeStamp, CMTime presentationDuration ) {
    
    CVPixelBufferRef *outputPixelBuffer = (CVPixelBufferRef *)sourceFrameRefCon;
    *outputPixelBuffer = CVPixelBufferRetain(pixelBuffer);
}

#pragma mark - 隐藏状态栏
- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

#pragma mark - NSStreamDelegate
-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    
    switch (eventCode) {
            
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream opened");
            break;
            
        case NSStreamEventHasBytesAvailable:
            if(1){
                uint8_t buffer[1024];
                int len;
                while ([_inputStream2 hasBytesAvailable]) {
                    len = [_inputStream2 read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        if (nil != output) {
                            //NSLog(@"server said: %@", output);
                            returnvalue=[output intValue];
                            if (returnvalue<=100)
                                returnID=returnvalue;
                        
                        }
                    }
                }
            }

            
            break;
            
        case NSStreamEventErrorOccurred:
            NSLog(@"Can not connect to the host!");
            break;
            
        case NSStreamEventEndEncountered:
            
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            break;
            
        case NSStreamEventHasSpaceAvailable:
            
            break;
            
            
            
        default:
            NSLog(@"Unknown event");
            
    }
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    
    
    NSString *newMessage = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"read data: %@",newMessage);
    hp2= [newMessage intValue];
    
    NSString *hpself= [NSString stringWithFormat:@"%d",hp1];
    [_socket writeData:[hpself dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    
    [_socket readDataWithTimeout:-1 tag:0];
    

}




@end
