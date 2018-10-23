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
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
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
