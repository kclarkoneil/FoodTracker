//
//  ViewController.swift
//  FoodTracker
//
//  Created by Kit Clark-O'Neil on 2018-09-07.
//  Copyright © 2018 Kit Clark-O'Neil. All rights reserved.
//

import UIKit
import os.log
import FirebaseDatabase
import Firebase
import FirebaseStorage


class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var ratingField: RatingField!

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMealMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The MealViewController is not inside a navigation controller.")
        }
    }
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var meal: Meal?
    let mealRef = Database.database().reference(withPath: "meal-item")
    let imageStorageRef = Storage.storage().reference(withPath: "image")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        if let meal = meal {
            navigationItem.title = meal.name
            nameTextField.text   = meal.name
            photoImageView.image = meal.image
            ratingField.rating = meal.rating
        }
        updateSaveButtonState()
        // Do any additional setup after loading the view, typically from a nib.
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        updateSaveButtonState()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = textField.text
    }
    
    //Upload image to Firebase Storage bucket and Retrieve URl, assign it to meal object and upload meal object to Databaseor
    func uploadMeal(data: Data, meal: Meal) {
        let storageRef = Storage.storage().reference(withPath: "images/\(meal.name)")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        storageRef.putData(data, metadata: metaData) { (returnData, error) in
            if error == nil {
                print("uploadComplete metadata: \(returnData)")
                storageRef.downloadURL(completion: { (url, error) in
                    if error == nil {
                meal.imageURL = url?.absoluteString
                let ref = self.mealRef.child("\(meal.name)")
                ref.setValue(meal.toAnyObject())
                    }
                    else {
                        print("urlupload incomplete error: \(error)")
                    }
                })
            }
            else {
                print("upload failed with error: \(error)")
        }
    }
    }
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        nameTextField.resignFirstResponder()
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self  
        present(imagePickerController, animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as?
            UIImage {
        photoImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    //Saves meal with imagename in database and image in storage bucket
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default,
                   type: .debug)
            return
        }
        let name = nameTextField.text ?? ""
        let photo = photoImageView.image!
        let rating = ratingField.rating
        
        meal = Meal(name: name, rating: rating, image: photo)
        
        if let newMeal = meal, let imageData = UIImageJPEGRepresentation(photo, 0.8) {
        
            uploadMeal(data: imageData, meal: newMeal)
        
        
        }
    }
    private func updateSaveButtonState() {
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
}

