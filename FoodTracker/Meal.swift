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
import FirebaseDatabase
import FirebaseAuth


class Meal: NSObject {
    
    let name:String
    var image: UIImage?
    let rating: Int
    let addedBy: String?
    var imageURL: String?
    
    //Initiate locally from ViewController
    init?(name:String, rating:Int, image: UIImage) {
        
        guard !name.isEmpty else {
            return nil
        }
        
        guard (rating >= 0) && (rating <= 5) else {
            return nil
        }
        
        self.name = name
        self.rating = rating
        self.addedBy = Auth.auth().currentUser!.email!
        self.image = image
        self.imageURL = nil
        
        
    }
    
    //Initiate remotely from Firebase
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: Any],
            let mealAddedBy = value["addedBy"] as? String,
            let mealName = value["name"] as? String,
            let mealRating = value["rating"] as? Int,
            let imageURL = value["imageURL"] as? String
            else {return nil}
        
        self.addedBy = mealAddedBy
        self.name = mealName
        self.rating = mealRating
        self.imageURL = imageURL
        super.init()
        if let URLString = URL(string: imageURL) {
        image = retrieveImageFromStorage(imageURL: URLString)
        }
    }
    
    //Helper method to convert meal object
    func toAnyObject() -> Any {
        return [
            "name": name,
            "rating": rating,
            "addedBy": addedBy!,
            "imageURL": imageURL ?? ""
        ]
    }

    func retrieveImageFromStorage(imageURL: URL) -> UIImage {
        
        var retrievedImage = UIImage()
        do {
            let data = try Data(contentsOf: imageURL)
            if let image = UIImage(data: data) {
                retrievedImage = image
            }
        }
        catch {
            print("Error retrieving image \(error)")
        }
        return retrievedImage
    }
}

