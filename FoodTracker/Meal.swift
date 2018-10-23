//
//  Meal.swift
//  FoodTracker
//
//  Created by Kit Clark-O'Neil on 2018-09-09.
//  Copyright © 2018 Kit Clark-O'Neil. All rights reserved.
//

import UIKit
import os.log
import Firebase
import FirebaseAuth


class Meal: NSObject {
    
    let name:String
    let image: UIImage?
    let rating: Int
    let addedBy: String
    
    init?(name:String, photo:UIImage?, rating:Int) {
        
        guard !name.isEmpty else {
            return nil
        }
        
        guard (rating >= 0) && (rating <= 5) else {
            return nil
        }
        self.name = name
        self.image = photo
        self.rating = rating
        self.addedBy = Auth.auth().currentUser!.email!
    }
    init?(snapshot: DataSnapshot) {
        guard
        let value = snapshot as? [String: Any],
        let addedBy = value["addedBy"] as? String,
        let name = value["name"] as? String,
        let rating = value["rating"] as? Int
        else {return}
        
        self.addedBy = addedBy
        self.name = name
        self.rating = rating
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "rating": rating,
            "addedBy": addedBy
        ]
    }
}
