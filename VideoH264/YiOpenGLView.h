

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface YiOpenGLView : UIView

/**
 *  创建GL
 */
- (void)setupGL;

- (UIImage* )displayPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end
