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
    var imageURL: String?
    let addedBy: String?
    let dateEaten: String
    
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
        self.image = image
        self.imageURL = nil
        self.addedBy = "\(Auth.auth().currentUser!)"
        
        let date = Date()
        self.dateEaten = date.description
        print("\(dateEaten)")
        
        
    }
    
    //Initiate remotely from Firebase
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: Any],
            let mealAddedBy = value["addedBy"] as? String,
            let mealName = value["name"] as? String,
            let mealRating = value["rating"] as? Int,
            let imageURL = value["imageURL"] as? String,
            let dateEaten = value["dateEaten"] as? String
            else {return nil}
        
        self.addedBy = mealAddedBy
        self.name = mealName
        self.rating = mealRating
        self.imageURL = imageURL
        self.dateEaten = dateEaten
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
            "imageURL": imageURL ?? "",
            "dateEaten": dateEaten
            
        ]
    }
    //Load image from bucket
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
    
    //Upload image to Firebase Storage bucket and Retrieve URl, assign it to meal object and upload meal object to Database
    func uploadMeal(data: Data) {
        let currentUser = Auth.auth().currentUser!
        let mealRef = Database.database().reference(withPath: "\(currentUser.uid)")
        let storageRef = Storage.storage().reference(withPath: "\(currentUser.uid)/\(self.name)")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        storageRef.putData(data, metadata: metaData) { (returnData, error) in
            if error == nil {
                print("uploadComplete metadata: \(String(describing: returnData))")
                storageRef.downloadURL(completion: { (url, error) in
                    if error == nil {
                        self.imageURL = url?.absoluteString
                        let ref = mealRef.child("\(self.name)")
                        ref.setValue(self.toAnyObject())
                    }
                    else {
                        print("url upload incomplete error: \(String(describing: error))")
                    }
                })
            }
            else {
                print("upload failed with error: \(String(describing: error))")
            }
        }
    }
    
    //Remove meal at original path if meal name is changed and new path is created
    func removeMealByName(name:String) {
        let currentUser = Auth.auth().currentUser!
        let mealRef = Database.database().reference(withPath: "\(currentUser.uid)/\(name)")
        let storageRef = Storage.storage().reference(withPath: "\(currentUser.uid)/\(name)")
        mealRef.removeValue { (error, _) in
            if error != nil {
                print("could not delete meal: \(name) due to error: \(String(describing: error))")
            }
        }
        storageRef.delete { (error) in
            if error != nil {
                print("could not delete image: \(name) due to error: \(String(describing: error))")
            }
        }
    }
}


