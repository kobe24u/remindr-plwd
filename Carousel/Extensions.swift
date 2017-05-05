//
//  Extensions.swift
//  Carousel
//
//  Created by Priyanka Gopakumar on 2/4/17.
//  Copyright © 2017 200OK. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString (urlString: String)
    {
        self.image = nil
        
        // check cache for image first
        if let cacheImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cacheImage
            return
        }
        
        //otherwise fire off a new download
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            if error != nil
            {
                print (error)
                return
            }
            
            DispatchQueue.main.async {
                
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    self.image = downloadedImage
                    
                }
            }
            
        }).resume()
        
    }
}
