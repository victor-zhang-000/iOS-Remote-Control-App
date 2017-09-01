//
//  InitViewController.m
//  VideoH264
//
//  Created by 张 溢 on 17/3/15.
//  Copyright © 2017年 yizhang. All rights reserved.
//

#import "InitViewController.h"
#import "ViewController.h"


@interface InitViewController ()
{
    int mode;
}

@end


@implementation InitViewController
@synthesize planeNum;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)goAction:(id)sender {
    mode=1;
    [self performSegueWithIdentifier:@"goSegue1" sender:self];
}

- (IBAction)goAction2:(id)sender {
    mode=2;
    [self performSegueWithIdentifier:@"goSegue1" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"goSegue1"]) {
        ViewController *receive = segue.destinationViewController;
        receive.gameMode = mode;
        if(planeNum.selectedSegmentIndex==0)
            receive.plane=1;
        else
            receive.plane=2;
        
    }
}

@end
