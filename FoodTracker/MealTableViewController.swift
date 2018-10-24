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


class MealTableViewController: UITableViewController {
    
    var meals = [Meal]()
    let mealRef = Database.database().reference(withPath: "meal-item")
    let imageStorageRef = Storage.storage().reference(withPath: "image")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mealRef.queryOrdered(byChild: "rating").observe(.value) { snapshot in
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
        
        mealRef.observe(.value, with: { snapshot in
            print(snapshot.value as Any)
        })
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
        
        guard let meal1 = Meal(name: "meal1", rating: 4, image: photo1!) else {
            fatalError("Unable to instantiate meal1")
        }
        guard let meal2 = Meal(name: "meal2", rating: 5, image: photo2!) else {
            fatalError("Unable to instantiate meal2")
        }
        guard let meal3 = Meal(name: "meal3", rating: 3, image: photo3!) else {
            fatalError("Unable to instantiate meal2")
        }
        meals += [meal1, meal2, meal3]
    }
    
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? MealViewController, let meal = sourceViewController.meal {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                
                meals[selectedIndexPath.row] = meal
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
                
            else {
                
                let newIndexPath = IndexPath(row: meals.count, section: 0)
                meals.append(meal)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            //saveMeals()
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new meal.", log: OSLog.default, type: .debug)
        case "ShowDetail":
            guard let mealDetailViewController = segue.destination as? MealViewController
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
            mealDetailViewController.meal = selectedMeal
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
            
        }
    }
    override func tableView(_ tableView: UITableView, commit editingStyle:
        UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            meals.remove(at: indexPath.row)
            //saveMeals()
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            
        }
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
}

