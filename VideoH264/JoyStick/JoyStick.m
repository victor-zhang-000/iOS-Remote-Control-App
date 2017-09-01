
#import "math.h"
#import "JoyStick.h"

#define kRadius ([self bounds].size.width * 0.5f)
#define kTrackRadius kRadius * 0.8f


@interface JoyStick ()
{
    CGFloat _x;
    CGFloat _y;
}

@property (strong, nonatomic) UIImageView *handleImageView;
@end

@implementation JoyStick

- (void)awakeFromNib
{
    [self commonInit];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    [self setRockerStyle:RockStyleOpaque];
    _mode=LEFT;
    
    
    if (!_handleImageView) {
        UIImage *handleImage = [UIImage imageNamed:@"handlePressed"];
        
        _handleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width*0.5f-handleImage.size.width*0.5f,
                                                                         self.bounds.size.height*0.5f-handleImage.size.height*0.5f,
                                                                         handleImage.size.width,
                                                                         handleImage.size.height)];
        _handleImageView.image = handleImage;

        [self addSubview:_handleImageView];
    }
    
    _x = 0;
    _y = 0;

}
- (void)setRockerStyle:(RockStyle)style
{
    //NSArray *imageNames = @[@"rockerOpaqueBg",@"rockerTranslucentBg"];
    //NSArray *imageNames = @[@"background",@"background"];
    
    [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"joystick3"]]];
    self.alpha=0.4;
    //[self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"rockerSquare"]]];
    
}

- (void)resetHandle
{
    _handleImageView.image = [UIImage imageNamed:@"handleNormal"];

    _x = 0.0;
    _y = 0.0;
    
    CGRect handleImageFrame = [_handleImageView frame];
    
    handleImageFrame.origin = CGPointMake(([self bounds].size.width - [_handleImageView bounds].size.width) * 0.5f,
                                          ([self bounds].size.height - [_handleImageView bounds].size.height) * 0.5f );
    
    [_handleImageView setFrame:handleImageFrame];

}

- (void)resetSteer
{
    _handleImageView.image = [UIImage imageNamed:@"handleNormal"];
    _x = 0.0;
    CGRect handleImageFrame = [_handleImageView frame];
    if (_mode==LEFT){
        handleImageFrame.origin = CGPointMake(([self bounds].size.width - [_handleImageView bounds].size.width) * 0.5f,
                                          ([self bounds].size.height - [_handleImageView bounds].size.height) * 0.5f -_y);
    }
    
    if (_mode==RIGHT){
        _y = 0.0;
        handleImageFrame.origin = CGPointMake(([self bounds].size.width - [_handleImageView bounds].size.width) * 0.5f,
                                              ([self bounds].size.height - [_handleImageView bounds].size.height) * 0.5f);
        
    }
    [_handleImageView setFrame:handleImageFrame];
    
}

- (void)setHandlePositionWithLocation:(CGPoint)location
{
    _x = location.x - kRadius;
    _y = -(location.y - kRadius);
    
    float r = sqrt(_x * _x + _y * _y);
    
    if((fabs(_x)>=kTrackRadius)||(fabs(_y)>=kTrackRadius))
    {
        if(fabs(_x)>=kTrackRadius)
            _x=_x>0? kTrackRadius:-kTrackRadius;
        if(fabs(_y)>=kTrackRadius)
            _y=_y>0? kTrackRadius:-kTrackRadius;
        
        location.x = _x + kRadius;
        location.y = -_y + kRadius;
        
        //[self rockerValueChanged];
        
    }
    
    [self rockerValueChanged];
    
    CGRect handleImageFrame = [_handleImageView frame];
    handleImageFrame.origin = CGPointMake(location.x - ([_handleImageView bounds].size.width * 0.5f),
                                          location.y - ([_handleImageView bounds].size.width * 0.5f));
    [_handleImageView setFrame:handleImageFrame];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _handleImageView.image = [UIImage imageNamed:@"handlePressed"];
    
    CGPoint location = [[touches anyObject] locationInView:self];
    
    [self setHandlePositionWithLocation:location];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self];
    
    [self setHandlePositionWithLocation:location];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self resetSteer];
    
    [self rockerValueChanged];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //[self resetHandle];
    [self resetSteer];
    
    [self rockerValueChanged];
}


- (void)rockerValueChanged
{
    
    _xValue=_x;
    _yValue=_y;
    
    
}


@end
