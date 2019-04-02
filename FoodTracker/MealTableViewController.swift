//
//  MealTableViewController.swift
//  FoodTracker
//
//  Created by Kit Clark-O'Neil on 2018-09-09.
//  Copyright © 2018 Kit Clark-O'Neil. All rights reserved.
//

import UIKit
import os.log
import Firebase
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth


class MealTableViewController: UITableViewController {
    
    var meals = [Meal]()
    let currentUser = Auth.auth().currentUser!
    var mealRef = Database.database().reference()
    var imageStorageRef = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mealRef = Database.database().reference(withPath: "\(currentUser.uid)")
        imageStorageRef = Storage.storage().reference(withPath: "\(currentUser.uid)")
        
        mealRef.queryOrdered(byChild: "dateEaten").observe(.value) { snapshot in
            print(snapshot)
            print(self.currentUser.uid)
            var newMeals = [Meal]()
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
                    if let newMeal = Meal(snapshot: snapshot) {
                        newMeals.append(newMeal)
                    }
                }
            }
            self.meals = newMeals
            print("\(self.meals.count)")
            
            if self.meals.count == 0 {
                self.loadSampleMeals()
            }
            self.tableView.reloadData()
        }
        navigationItem.leftBarButtonItem = editButtonItem
        
        //Add meal Button
        let addMealButton = UIButton(type: .system)
        addMealButton.setTitle("Add New Meal", for: .normal)
        addMealButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        addMealButton.backgroundColor = .white
        self.view.addSubview(addMealButton)
        
        addMealButton.translatesAutoresizingMaskIntoConstraints = false
        addMealButton.bottomAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        addMealButton.centerXAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        addMealButton.widthAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.widthAnchor, constant: 1).isActive = true
        addMealButton.heightAnchor.constraint(equalToConstant: 80)
        
        addMealButton.addTarget(self, action: #selector(self.addMeal(sender:)), for: .touchUpInside)
        
    }
    @objc func addMeal(sender: UIButton) {
        self.performSegue(withIdentifier: "NewMealSegue", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return meals.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MealTableViewCell", for: indexPath) as? MealTableViewCell else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        let meal = meals[indexPath.row]
        cell.nameLabel.text = meal.name
        cell.PhotoImageView.image = meal.image
        cell.ratingField.rating = meal.rating
    
        return cell
    }
    
    private func loadSampleMeals() {
        let photo1 = UIImage(named: "meal1")
        let photo2 = UIImage(named: "meal2")
        let photo3 = UIImage(named: "meal3")
        
        guard let meal1 = Meal(name: "Brushetta", rating: 4, image: photo1!) else {
            fatalError("Unable to instantiate meal1")
        }
        guard let meal2 = Meal(name: "Chicken", rating: 5, image: photo2!) else {
            fatalError("Unable to instantiate meal2")
        }
        guard let meal3 = Meal(name: "Spaghetti", rating: 3, image: photo3!) else {
            fatalError("Unable to instantiate meal2")
        }
        meals += [meal1, meal2, meal3]
    }
    
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
//        if let sourceViewController = sender.source as? MealViewController, let meal = sourceViewController.meal {
//            if let selectedIndexPath = tableView.indexPathForSelectedRow {
//
//                meals[selectedIndexPath.row] = meal
//                tableView.reloadRows(at: [selectedIndexPath], with: .none)
//            }
//
//            else {
//
//                let newIndexPath = IndexPath(row: meals.count, section: 0)
//                meals.append(meal)
//                tableView.insertRows(at: [newIndexPath], with: .automatic)
//            }
//            //saveMeals()
//        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "NewMealSegue":
            os_log("Adding a new meal.", log: OSLog.default, type: .debug)
        case "EditMealSegue":
            guard let navigationController = segue.destination as? UINavigationController, let mealViewController = navigationController.viewControllers[0] as? MealViewController
                else {
                    fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedMealCell = sender as? MealTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            guard let indexPath = tableView.indexPath(for: selectedMealCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedMeal = meals[indexPath.row]
            mealViewController.meal = selectedMeal
//            mealDetailViewController.editMeal = true
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
            
        }
    }
    override func tableView(_ tableView: UITableView, commit editingStyle:
        UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deletedMeal = meals[indexPath.row]
            meals.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            let onlineRef = Database.database().reference(withPath: "\(currentUser.uid)/\(deletedMeal.name)")
            print(onlineRef)
            onlineRef.removeValue { (error, _) in
                if error != nil {
                    print("could not delete \(deletedMeal) due to error: \(String(describing: error))")
                }
        }
            let storageRef = Storage.storage().reference(withPath: "\(currentUser.uid)/\(deletedMeal.name)")
            storageRef.delete(completion: { (error) in
                    if error != nil {
                        print("could not delete image due to error: \(String(describing: error))")
                    }
                })
    }
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            self.dismiss(animated: true, completion: nil)
        } catch (let error) {
            print("Auth sign out failed: \(error)")
        }
    }
}


