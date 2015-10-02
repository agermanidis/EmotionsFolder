//
//  OpencvTest.cpp
//  EmotionsFolder
//
//  Created by Anastasis Germanidis on 7/25/15.
//  Copyright (c) 2015 Anastasis Germanidis. All rights reserved.
//

#include "FaceRecognizer.h"
#include "Tracker.h"

#include "CoreFoundation/CoreFoundation.h"

double euclidean_distance(cv::Point point1, cv::Point point2) {
    double dx = point2.x - point1.x;
    double dy = point2.y - point1.y;
    return sqrt(dx*dx + dy*dy);
}

double normalized_distance(cv::Point point1, cv::Point point2, double mean, double stdev) {
    return (euclidean_distance(point1, point2) - mean)/stdev;
}

cv::Point get_point(int i, cv::Mat &shape) {
    int n = shape.rows/2;
    return cv::Point(shape.at<double>(i,0), shape.at<double>(i+n,0));
}

double* get_all_distances_between_points(cv::Mat &shape) {
    int n = shape.rows/2;
    int c = 0;
    double *ret;
    ret = (double *)malloc(n*(n-1) * sizeof(double));
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < shape.rows/2; j++) {
            if (i != j) {
                ret[c++] = euclidean_distance(get_point(i, shape), get_point(j, shape));
            }
        }
    }
    return ret;
}

double calculate_stdev(double *d, int n)
{
    double m=0.0, sum_deviation=0.0;
    for(int i =0; i<n;++i) {
        m+=d[i];
    }
    m=m/n;
    for(int i=0; i<n;++i) {
        sum_deviation+=(d[i]-m)*(d[i]-m);
    }
    return sqrt(sum_deviation/n);
}

double calculate_mean(double *d, int n)
{
    double m=0.0;
    for(int i =0; i<n;++i)
    {
        m+=d[i];
    }
    m=m/n;
    return m;
}

int NEUTRAL = 0;
int HAPPINESS = 1;
int SADNESS = 2;
int ANGER = 3;
int SURPRISE = 4;

int recognize_emotion(cv::Mat &face_shape) {
    int n = face_shape.rows/2;
    double *distances = get_all_distances_between_points(face_shape);
    double mean = calculate_mean(distances, n*(n-1));
    double stdev = calculate_stdev(distances, n*(n-1));

    double dist_21_39 = normalized_distance(get_point(21, face_shape), get_point(39, face_shape), mean, stdev);
    double dist_48_57 = normalized_distance(get_point(48, face_shape), get_point(57, face_shape), mean, stdev);
    double dist_30_51 = normalized_distance(get_point(30, face_shape), get_point(51, face_shape), mean, stdev);
    double dist_30_57 = normalized_distance(get_point(30, face_shape), get_point(57, face_shape), mean, stdev);
    
    if (dist_21_39 < -1.5) {
        return ANGER;
    } else if ((dist_48_57 > -1.25) && (dist_30_51 < -1.35)) {
        return HAPPINESS;
    } else if (dist_30_57 > -0.6) {
        return SURPRISE;
    } else if (dist_30_57 < -0.8) {
        return SADNESS;
    } else {
        return NEUTRAL;
    }
}

int lastEmotion = 0;
bool capturing = false;
bool started = false;
cv::Mat lastFrame;

int FaceRecognizer::getLastEmotion() {
    return lastEmotion;
}

void FaceRecognizer::stopCapturing() {
    capturing = false;
}

cv::Mat FaceRecognizer::getLastFrame() {
    return lastFrame;
}

bool failed = false;
bool gotFrame = false;

bool FaceRecognizer::hasFrame() {
    return started && gotFrame;
}

int FaceRecognizer::startCapturing()
{
    started = false;
    capturing = true;
    //parse command line arguments
    char ftFile[256],conFile[256],triFile[256];
    bool fcheck = false; double scale = 1; int fpd = -1;
    
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    CFURLRef resourcesURL = CFBundleCopyResourcesDirectoryURL(mainBundle);
    char path[PATH_MAX];
    if (!CFURLGetFileSystemRepresentation(resourcesURL, TRUE, (UInt8 *)path, PATH_MAX))
    {
    }
    CFRelease(resourcesURL);
    
    std::strcpy(ftFile, path);
    std::strcpy(conFile, path);
    std::strcpy(triFile, path);
    
    std::strcat(ftFile, "/face.tracker");
    std::strcat(conFile, "/face.con");
    std::strcat(triFile, "/face.tri");
    
    std::vector<int> wSize1(1); wSize1[0] = 7;
    std::vector<int> wSize2(3); wSize2[0] = 11; wSize2[1] = 9; wSize2[2] = 7;
    int nIter = 5; double clamp=3,fTol=0.01;
    FACETRACKER::Tracker model(ftFile);
    cv::Mat tri=FACETRACKER::IO::LoadTri(triFile);
    cv::Mat con=FACETRACKER::IO::LoadCon(conFile);
    
    cv::Mat frame,gray,im; std::string text;
    CvCapture* camera = cvCreateCameraCapture(CV_CAP_ANY);
    if(!camera)return -1;
    lastEmotion = NEUTRAL;
    bool failed = true;
    int count = 0;
    IplImage* I;
    while(capturing){
        try
        {
            if (count++ > 10) {
                started = true;
            }
            I = cvQueryFrame(camera); if(!I)continue; frame = I;
            lastFrame = frame.clone();
            if(scale == 1)im = frame;
            else cv::resize(frame,im,cv::Size(scale*frame.cols,scale*frame.rows));
            cv::flip(im,im,1);
            cv::cvtColor(im,gray,CV_BGR2GRAY);
            std::vector<int> wSize; if(failed)wSize = wSize2; else wSize = wSize1;
            if(model.Track(gray,wSize,fpd,nIter,clamp,fTol,fcheck) == 0){
                failed = false;
                gotFrame = true;
                lastEmotion = recognize_emotion(model._shape);
            } else {
                gotFrame = false;
            }
        }
        catch (cv::Exception& e) {
            std::cout << "An exception occurred" << '\n';
            failed = true;
            break;
        }
        usleep(100000);
    }
    cvReleaseCapture( &camera );
    if (failed) FaceRecognizer::startCapturing();
    return 0;
}
