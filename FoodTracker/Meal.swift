//
//  Meal.swift
//  FoodTracker
//
//  Created by Kit Clark-O'Neil on 2018-09-09.
//  Copyright © 2018 Kit Clark-O'Neil. All rights reserved.
//

import UIKit
import os.log

class Meal: NSObject {
    
    var name:String
    var image: UIImage?
    var rating: Int
    var imageName: String
    
    init?(name:String, photo:UIImage?, rating:Int, imageName: String) {
        
        guard !name.isEmpty else {
            return nil
        }
        
        guard (rating >= 0) && (rating <= 5) else {
            return nil
        }
        self.imageName = imageName
        self.name = name
        self.image = photo
        self.rating = rating
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "image": imageName,
            "rating": rating
        ]
    }
}
