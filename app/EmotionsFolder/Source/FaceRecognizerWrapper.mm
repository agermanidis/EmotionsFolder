#import "FaceRecognizer.h"
#import "FaceRecognizerWrapper.h"
#import <opencv2/core/core_c.h>

@implementation FaceRecognizerWrapper

- (void) startCapturing {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        FaceRecognizer::startCapturing();
    });
}

- (void)stopCapturing {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        FaceRecognizer::stopCapturing();
    });
}

- (CGImageRef)CGImageFromCvMat:(cv::Mat)aMat {
    try {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        unsigned char* data = new unsigned char[4*aMat.cols * aMat.rows];
        for (int y = 0; y < aMat.rows; ++y)
        {
            cv::Vec3b *ptr = aMat.ptr<cv::Vec3b>(y);
            unsigned char *pdata = data + 4*y*aMat.cols;
            
            for (int x = 0; x < aMat.cols; ++x, ++ptr) {
                *pdata++ = (*ptr)[2];
                *pdata++ = (*ptr)[1];
                *pdata++ = (*ptr)[0];
                *pdata++ = 0;
            }
        }
        CGContextRef context = CGBitmapContextCreate(data, aMat.cols, aMat.rows, 8, 4*aMat.cols, colorSpace, kCGImageAlphaNoneSkipLast);
        CGImageRef ret = CGBitmapContextCreateImage(context);
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        free(data);
        return ret;
    } catch(int e) {
        return nil;
    }
}

- (bool) hasFrame {
    return FaceRecognizer::hasFrame();
}

- (int) getLastEmotion {
    return FaceRecognizer::getLastEmotion();
}

- (CGImageRef) getLastFrame {
    if (!FaceRecognizer::hasFrame()) return nil;
    cv::Mat frame = FaceRecognizer::getLastFrame();
    CGImageRef ret = [self CGImageFromCvMat: frame];
    return ret;
}

@end
