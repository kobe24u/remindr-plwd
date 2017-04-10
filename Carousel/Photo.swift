//
//  Photo.swift
//  Carousel
//
//  Created by Vincent Liu on 26/3/17.
//  Copyright © 2017 200OK. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Photo
{
    var title = ""
    var featuredImage: UIImage
    var color: UIColor
    var audioURL: String?
    
    init(title: String, featuredImage: UIImage, color: UIColor, audioURL: String)
    {
        self.title = title
        self.featuredImage = featuredImage
        self.color = color
        self.audioURL = audioURL
    }
    
//    static func fetchInterests() -> [Photo]
//    {
//        return [
//            Photo(title: "Tap to add or delete photo", featuredImage: UIImage(named: "husband")!, color: UIColor(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 0.6)),
//        ]
//    }
}
