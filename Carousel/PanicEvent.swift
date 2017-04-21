//
//  PanicEvent.swift
//  Carousel
//
//  Created by Priyanka Gopakumar on 10/4/17.
//  Copyright © 2017 200OK. All rights reserved.
//

import Foundation

class PanicEvent: NSObject {
    var receivedDate: String?
    var receivedTime: String?
    var receivedLat: String?
    var receivedLng: String?
    var resolvedDate: String?
    var resolvedTime: String?
    var resolved: String?
    
    override init() {
    
    }
    
    init(receivedDate: String, receivedTime: String, receivedLat: String, receivedLng: String)
    {
        self.receivedDate = receivedDate
        self.receivedTime = receivedTime
        self.receivedLat = receivedLat
        self.receivedLng = receivedLng
        self.resolvedDate = "nil"
        self.resolvedTime = "nil"
        self.resolved = "false"
    }
}
