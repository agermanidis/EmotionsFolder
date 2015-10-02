#import <Foundation/Foundation.h>

typedef void(^EmotionDetectionCallback)(int, CGImageRef);

@interface FaceRecognizerWrapper : NSObject
- (void)startCapturing;
- (void)stopCapturing;
- (CGImageRef)getLastFrame;
- (int)getLastEmotion;
- (bool)hasFrame;
@end
