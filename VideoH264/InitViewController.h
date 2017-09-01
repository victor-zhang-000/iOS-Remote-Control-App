//
//  InitViewController.h
//  VideoH264
//
//  Created by 张 溢 on 17/3/15.
//  Copyright © 2017年 yizhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InitViewController : UIViewController
- (IBAction)goAction:(id)sender;
- (IBAction)goAction2:(id)sender;
@property (strong, nonatomic) IBOutlet UISegmentedControl *planeNum;

@end
