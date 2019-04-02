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
import FirebaseAuth


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
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!
    
    var meal: Meal?
    let currentUser = Auth.auth().currentUser!
    var originalMealName: String?
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        nameTextField.delegate = self
        cameraButton.isHidden = true
        cameraButton.isUserInteractionEnabled = false
        galleryButton.isHidden = true
        galleryButton.isUserInteractionEnabled = false
        if let meal = meal {
            navigationItem.title = meal.name
            nameTextField.text   = meal.name
            photoImageView.image = meal.image
            ratingField.rating = meal.rating
            originalMealName = meal.name
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
    
    @IBAction func photoEditDidTap(_ sender: UITapGestureRecognizer) {
     updateImageView()
    }
    
    @IBAction func galleryButtonPressed(_ sender: UIButton) {
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
        updateImageView()
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
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
            
        newMeal.uploadMeal(data: imageData)
            if originalMealName != nil, newMeal.name != originalMealName {
        newMeal.removeMealByName(name: originalMealName!)
        }
    }
            
    }
    private func updateImageView() {
        cameraButton.isHidden = !cameraButton.isHidden
        cameraButton.isUserInteractionEnabled = !cameraButton.isUserInteractionEnabled
        galleryButton.isHidden = !galleryButton.isHidden
        galleryButton.isUserInteractionEnabled = !galleryButton.isUserInteractionEnabled
        
        print(cameraButton.isHidden)
        if cameraButton.isHidden {
            photoImageView.alpha = 1
        }
        else {
            photoImageView.alpha = 0.25
        }
    }
    private func updateSaveButtonState() {
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
}

