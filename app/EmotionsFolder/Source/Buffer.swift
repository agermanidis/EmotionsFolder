//
//  Buffer.swift
//  EmotionsFolder
//
//  Created by Anastasis Germanidis on 9/28/15.
//  Copyright (c) 2015 Anastasis Germanidis. All rights reserved.
//

class Buffer {
    var items : NSMutableArray
    var capacity : Int
    
    init(capacity:Int) {
        self.items = NSMutableArray(capacity: capacity)
        self.capacity = capacity
    }
    
    func empty() {
        self.items = NSMutableArray(capacity: capacity)
    }
    
    func atCapacity() -> Bool {
        return self.items.count == self.capacity
    }

    func add(item:AnyObject) {
        if items.count == capacity {
            items.removeObjectAtIndex(0)
        }
        items.addObject(item)
    }

    func freeze() -> [AnyObject]? {
        if items.count != capacity {
            return nil
        } else {
            return Array(items)
        }                  
    }
}
