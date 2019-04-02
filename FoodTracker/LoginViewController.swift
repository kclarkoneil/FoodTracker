//
//  LoginViewController.swift
//  FoodTracker
//
//  Created by Kit Clark-O'Neil on 2018-09-10.
//  Copyright © 2018 Kit Clark-O'Neil. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class LoginViewController: UIViewController {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    
    
    var userName: String?
    var passWord: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Auth.auth().addStateDidChangeListener { (_ , user) in
            if user != nil {
                self.usernameTextField.text = nil
                self.passwordTextField.text = nil
                self.performSegue(withIdentifier: "LoginSegue", sender: self)
            }
        }
        passwordTextField.isSecureTextEntry = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(_ sender: UIButton) {
        
        Auth.auth().signIn(withEmail: usernameTextField.text!, password: passwordTextField.text!) { user, error in
            if let error = error, user == nil {
                let alert = UIAlertController(title: "Sign In Failed",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func createAccount(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Create Account", message: "Enter your account details", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Enter E-mail"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter Password"
            textField.isSecureTextEntry = true
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard
                let enteredEmail = alertController.textFields![0].text,
                let enteredPassword = alertController.textFields![1].text,
                enteredEmail.count > 0,
                enteredPassword.count > 0
                else {
                    return
            }
            Auth.auth().createUser(withEmail: enteredEmail, password: enteredPassword, completion: { (_, error) in
                if error != nil {
                    let errorAlert = UIAlertController(title: "LoginFailed", message: "Login Failed", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                }
                Auth.auth().signIn(withEmail: enteredEmail, password: enteredPassword, completion: nil)
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
        
    }
}
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        }
        if textField == passwordTextField {
            textField.resignFirstResponder()
        }
        return true
    }
}
