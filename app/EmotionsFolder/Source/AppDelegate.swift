//
//  AppDelegate.swift
//  EmotionsFolder
//
//  Created by Anastasis Germanidis on 9/27/15.
//  Copyright (c) 2015 Anastasis Germanidis. All rights reserved.
//

import Cocoa


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var showNotificationsItem: NSMenuItem!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)

    var currentlyCapturing = true

    @IBOutlet weak var captureCaption: NSMenuItem!
    @IBOutlet weak var captureButton: NSMenuItem!
    
    let recorder = Recorder()
    
    func applicationDidFinishLaunching(notification: NSNotification) {
        setStatusIconToEmotion(Constants.NEUTRAL)
        statusItem.menu = statusMenu
        ensureDestinationPathExists()
        updateCaptureState()
        firstTimeCheck()
        updateCountText()
    }

    func setStatusIconToEmotion(emotion:Int) {
        var imageName:String
        switch emotion {
        case Constants.HAPPINESS:
            imageName = "happyfolder"
            break
        case Constants.SADNESS:
            imageName = "sadfolder"
            break
        case Constants.ANGER:
            imageName = "angryfolder"
            break
        case Constants.SURPRISE:
            imageName = "surprisedfolder"
            break
        default:
            imageName = "neutralfolder"
        }
        let icon = NSImage(named: imageName)
        statusItem.image = icon
    }
    
    func firstTimeCheck() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.boolForKey("hasBeenOpened") {
            return
        }
        FinderFavorites.add(defaultDestinationPath())
        defaults.setValue(true, forKey: "hasBeenOpened")
    }
    
    var lastHour = NSDate()
    var hourCount = 0
    
    func updateCountText() {
        var emotionText = "emotion"
        if hourCount != 1 {
            emotionText += "s"
        }
        captureCaption.title = String(format: "%d %@ saved in the past hour", hourCount, emotionText)
    }
    
    func getHourFromDate(date:NSDate) -> Int {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: date)
        return components.hour
    }
    
    func incHourCount() {
        if getHourFromDate(NSDate()) == getHourFromDate(lastHour) {
            hourCount += 1
        } else {
            hourCount = 0
            lastHour = NSDate()
        }
        updateCountText()
    }
    
    func updateCaptureState() {
        if !currentlyCapturing {
            captureButton.title = "Start capturing"
            self.recorder.stopRecording()
        } else {
            captureButton.title = "Stop capturing"
            
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                let emotionChange = {
                    emotion in
                    self.setStatusIconToEmotion(emotion)
                }
                                
                self.recorder.startRecording(emotionChange, callback: {
                    emotion, images in
                    self.incHourCount()
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) { [unowned self] in
                        Outputter.save(images, outputDirectory: self.currentDestinationPath(), emotion: Int(emotion))
                    }
                })
            }
        }
    }

    @IBAction func toggleCapturingButtonPressed(sender: AnyObject) {
        currentlyCapturing = !currentlyCapturing
        updateCaptureState()
    }
    
    func ensureDestinationPathExists() {
        var isDir = ObjCBool(false)
        if !NSFileManager().fileExistsAtPath(currentDestinationPath()) {
            var error: NSError?
            NSFileManager.defaultManager().createDirectoryAtPath(currentDestinationPath(), withIntermediateDirectories: true, attributes: nil, error: &error)
            println("created directory at " + currentDestinationPath())
        }
    }
    
    func userDirectory() -> String {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.ApplicationDirectory, .UserDomainMask, true) as! Array<String>
        let appPath = dirPaths[0] as String!
        let slashIndex = appPath.rangeOfString("/", options: .BackwardsSearch)?.startIndex
        return appPath.substringToIndex(slashIndex!)
    }
    
    func defaultDestinationPath() -> String {
        println("default destination path")
        return userDirectory() + "/Emotions"
    }

    func setDestinationPath(path : String) {
        FinderFavorites.remove(currentDestinationPath())
        println("setting destination path to " + path)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(path, forKey: "destinationPath")
        FinderFavorites.add(currentDestinationPath())
    }
    
    func currentDestinationPath() -> String {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.stringForKey("destinationPath") ?? defaultDestinationPath()
    }
    
    @IBAction func quitButtonPressed(sender: NSMenuItem) {
        println("quit button pressed")
        NSApplication.sharedApplication().terminate(self)
    }
    
    @IBAction func changeDestinationButtonPressed(sender: AnyObject) {
        let openPanel = NSOpenPanel()
        openPanel.directoryURL = NSURL(fileURLWithPath: currentDestinationPath())
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.canCreateDirectories = true
        let result = openPanel.runModal()
        if result == NSFileHandlingPanelOKButton {
            if openPanel.URL != nil {
                self.setDestinationPath(openPanel.URL!.path!)
            }
        }
    }
}

