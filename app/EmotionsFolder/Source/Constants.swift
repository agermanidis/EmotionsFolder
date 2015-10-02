//
//  Constants.swift
//  EmotionsFolder
//
//  Created by Anastasis Germanidis on 9/29/15.
//  Copyright (c) 2015 Anastasis Germanidis. All rights reserved.
//

class Constants {
    static let CLIP_DURATION = 4
    static let CAPTURE_RATE = 0.5
    static let RECALIBRATION_RATE = 60.0
    static let EMOTION_CAPTURE_THRESHOLD = 1.5

    // using ints instead of an Enum for easy interop with Obj-C/C++
    static let NEUTRAL = 0
    static let HAPPINESS = 1
    static let SADNESS = 2
    static let ANGER = 3
    static let SURPRISE = 4
}
