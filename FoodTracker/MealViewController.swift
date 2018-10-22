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
    let ref = Database.database().reference(withPath: "meal-item")
    
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
    
    //Upload image to Firebase Storage bucket
    func uploadImage(data: Data, imageName : String) {
        let storageRef = Storage.storage().reference(withPath: "images/\(imageName)")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        storageRef.putData(data, metadata: metaData) { (returnData, error) in
            if error != nil {
                print("uploadComplete metadata: \(returnData)")
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
            UIImage, let imageData = UIImageJPEGRepresentation(selectedImage, 0.8) {
            uploadImage(data: imageData, imageName: meal!.name)
        photoImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default,
                   type: .debug)
            return
        }
        let name = nameTextField.text ?? ""
        let imageName = "Access from bucket?"
        let photo = photoImageView.image
        let rating = ratingField.rating
        
        meal = Meal(name: name, photo: photo, rating: rating, imageName: imageName)
        if meal != nil {
        let mealRef = ref.child("meal-item/\(meal!.name)")
        mealRef.setValue(meal!.toAnyObject())
        }
    }
    private func updateSaveButtonState() {
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
}

