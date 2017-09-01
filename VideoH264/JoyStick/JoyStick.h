

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, RockStyle)
{
    RockStyleOpaque = 0,
    RockStyleTranslucent 
};

typedef NS_ENUM(NSInteger,MODE){
    LEFT,
    RIGHT
};



@interface JoyStick : UIView


@property (nonatomic) CGFloat xValue;
@property (nonatomic) CGFloat yValue;
@property (nonatomic) MODE mode;


- (void)setRockerStyle:(RockStyle)style;

@end

