//
//  Outputter.swift
//  EmotionsFolder
//
//  Created by Anastasis Germanidis on 9/28/15.
//  Copyright (c) 2015 Anastasis Germanidis. All rights reserved.
//

class Outputter {
    static func emotionToString(emotion : Int) -> String? {
        switch emotion {
        case Constants.HAPPINESS:
            return "Happiness"
        case Constants.SADNESS:
            return "Sadness"
        case Constants.ANGER:
            return "Anger"
        case Constants.SURPRISE:
            return "Surprise"
        default:
            return nil
        }
    }
    
    static func generateURL(outputDirectory : String, emotion : Int) -> NSURL {
        let emotionString = emotionToString(emotion)
        let now = NSDate()
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "h.mm a"
        let timeString = timeFormatter.stringFromDate(now)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-YYYY"
        let dateString = dateFormatter.stringFromDate(now)
        let basename = String(format: "%@ on %@ at %@.gif", emotionString!, dateString, timeString)
        return NSURL(fileURLWithPath: outputDirectory)!.URLByAppendingPathComponent(basename)
    }
    
    static func save(images:[CGImage], outputDirectory:String, emotion:Int) {
        let url = generateURL(outputDirectory, emotion: emotion)
        if NSFileManager().fileExistsAtPath(url.path!) {
            return
        }
        let nRepeats = Int(Constants.CAPTURE_RATE*10)
        let destination = CGImageDestinationCreateWithURL(url, kUTTypeGIF, images.count * nRepeats, nil)
        let fileProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]
        CGImageDestinationSetProperties(destination, fileProperties)
        for image in images {
            for j in 0..<nRepeats {
                CGImageDestinationAddImage(destination, image, nil)
            }
        }
        CGImageDestinationFinalize(destination)
    }
}
