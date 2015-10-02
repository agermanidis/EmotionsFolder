//
//  FinderFavorites.swift
//  EmotionsFolder
//
//  Created by Anastasis Germanidis on 9/27/15.
//  Copyright (c) 2015 Anastasis Germanidis. All rights reserved.
//

class FinderFavorites {
    static func add(path:String) {
        let url = NSURL.fileURLWithPath(path, isDirectory: true) as! CFURLRef
        let favoriteItemsRef = LSSharedFileListCreate(
                nil,
                kLSSharedFileListFavoriteItems.takeRetainedValue(),
                nil
        ).takeRetainedValue() as LSSharedFileListRef?

        if favoriteItemsRef != nil {
            let favoriteItems: NSArray = LSSharedFileListCopySnapshot(favoriteItemsRef, nil).takeRetainedValue() as NSArray
            let item = LSSharedFileListInsertItemURL(
                    favoriteItemsRef,
                    favoriteItems.lastObject as! LSSharedFileListItemRef,
                    "Emotions" as CFStringRef,
                    nil,
                    url,
                    nil,
                    nil
            )
        }
    }
    
    static func remove(path:String) -> Bool {
        let url = NSURL.fileURLWithPath(path, isDirectory: true) as! CFURLRef
        let favoriteItemsRef = LSSharedFileListCreate(
                nil,
                kLSSharedFileListFavoriteItems.takeRetainedValue(),
                nil
        ).takeRetainedValue() as LSSharedFileListRef?

        let favoriteItems: NSArray = LSSharedFileListCopySnapshot(favoriteItemsRef, nil).takeRetainedValue() as NSArray
        for item in favoriteItems  {
            let resolutionFlags : UInt32 = UInt32(kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes)
            var itemUrl = LSSharedFileListItemCopyResolvedURL(item as! LSSharedFileListItem, resolutionFlags, nil).takeRetainedValue() as NSURL
            if itemUrl.isEqual(url) {
                LSSharedFileListItemRemove(favoriteItemsRef, item as! LSSharedFileListItem)
                return true
            }
        }

        return false
    }
}
