#include <opencv2/opencv.hpp>

class FaceRecognizer
{
public:
    static int getLastEmotion();
    static cv::Mat getLastFrame();
    static bool hasFrame();
    static int startCapturing();
    static void stopCapturing();
};
