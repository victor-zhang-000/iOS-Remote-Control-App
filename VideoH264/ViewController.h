//
//  ViewController.h
//  VideoH264
//
//  Created by 张 溢 on 17/1/20.
//  Copyright © 2017年 yizhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JoyStick.h"
#import "GCDAsyncSocket.h"



@interface ViewController : UIViewController <NSStreamDelegate,GCDAsyncSocketDelegate>

@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;

@property (nonatomic, strong) NSInputStream *inputStream2;
@property (nonatomic, strong) NSOutputStream *outputStream2;

@property (strong, nonatomic) IBOutlet JoyStick *JoyStickLeft;
@property (strong, nonatomic) IBOutlet JoyStick *JoyStickRight;

@property(strong)  GCDAsyncSocket *socket;
@property (assign, nonatomic) int gameMode;
@property (assign, nonatomic) int plane;

- (IBAction)test:(id)sender;

- (IBAction)goBack:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundView;

@end

