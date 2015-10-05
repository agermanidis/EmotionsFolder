//
//  Recorder.swift
//  EmotionsFolder
//
//  Created by Anastasis Germanidis on 9/28/15.
//  Copyright (c) 2015 Anastasis Germanidis. All rights reserved.
//

import Cocoa

typealias EmotionChangeCallback = (Int) -> ()
typealias DetectionCallback = (Int, [CGImage]) -> ()

class Recorder : NSObject {
    var callback : DetectionCallback?
    var emotionChange : EmotionChangeCallback?
    var timer : NSTimer?
    var recalibrationTimer : NSTimer?
    let buffer = Buffer(capacity: Int(Double(Constants.CLIP_DURATION)/Constants.CAPTURE_RATE))
    let faceRecognizer = FaceRecognizerWrapper()
    var currentEmotion = 0
    var emotionDuration = 0.0
    
    func captureScreenshot() -> CGImage {
        let displayId = CGDirectDisplayID(NSScreen.mainScreen()!.deviceDescription["NSScreenNumber"] as! Int)
        return CGDisplayCreateImage(displayId).takeRetainedValue()
    }

    func startRecording(emotionChange: EmotionChangeCallback, callback: DetectionCallback) {
        self.emotionChange = emotionChange
        self.callback = callback
        buffer.empty()
        faceRecognizer.startCapturing()
        timer = NSTimer.scheduledTimerWithTimeInterval(
            Constants.CAPTURE_RATE,
            target: self,
            selector: "captureNext",
            userInfo: nil,
            repeats: true
        )
//        recalibrationTimer = NSTimer.scheduledTimerWithTimeInterval(
//            Constants.RECALIBRATION_RATE,
//            target: self,
//            selector: "recalibrate",
//            userInfo: nil,
//            repeats: true
//        )
    }

    func recalibrate() {
        faceRecognizer.stopCapturing()
        faceRecognizer.startCapturing()
    }
    
    func stopRecording() {
        faceRecognizer.stopCapturing()
        timer?.invalidate()
        timer = nil
    }

    func createComposition(screenshot:CGImage, face:CGImage) -> CGImage {
        let normalized = ImageUtils.normalizeImage(screenshot).takeRetainedValue()
        let width = CGImageGetWidth(normalized)
        let height = CGImageGetHeight(normalized)
        let bytesPerRow = CGImageGetBytesPerRow(normalized)
        let bitsPerComponent = CGImageGetBitsPerComponent(normalized)
        let colorSpace = CGImageGetColorSpace(normalized)
        let bitmapInfo = CGBitmapInfo(CGImageAlphaInfo.NoneSkipLast.rawValue)
        let newWidth = 864
        let newHeight = 540
        let context = CGBitmapContextCreate(nil, newWidth, newHeight, bitsPerComponent, 4*newWidth, colorSpace, bitmapInfo)
        CGContextDrawImage(context, CGRectMake(CGFloat(0.0), CGFloat(0.0), CGFloat(newWidth), CGFloat(newHeight)), normalized)
        CGContextDrawImage(context, CGRectMake(CGFloat(newWidth)-CGFloat(360), CGFloat(0), CGFloat(360), CGFloat(200)), face)
        return CGBitmapContextCreateImage(context)
    }
    
    func updateEmotion() {
        let newEmotion = Int(faceRecognizer.getLastEmotion())
        println(newEmotion)
        if currentEmotion == newEmotion {
            if currentEmotion == 0 {
                return
            }
            emotionDuration += Constants.CAPTURE_RATE
            
            if emotionDuration > Constants.EMOTION_CAPTURE_THRESHOLD && buffer.atCapacity() {
                let images = buffer.freeze() as! [CGImage]
                println(images)
                self.callback!(currentEmotion, images)
                self.resetDetection()
            }
        } else {
            currentEmotion = newEmotion
            emotionDuration = 0.0
            self.emotionChange!(currentEmotion)
        }
    }
    
    func resetDetection() {
        currentEmotion = 0
        emotionDuration = 0.0
    }
    
    func captureNext() {
        println("capture next")
        if !faceRecognizer.hasFrame() {
            return
        }
        let face = faceRecognizer.getLastFrame()
        if (face != nil) {
            let screenshot = captureScreenshot()
            let image = createComposition(screenshot, face: face.takeRetainedValue())
            buffer.add(image)
            updateEmotion()
        }
    }
}
