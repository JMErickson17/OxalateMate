//
//  FoodListVC.swift
//  OxalateMate
//
//  Created by Justin Erickson on 2/8/18.
//  Copyright © 2018 Justin Erickson. All rights reserved.
//

import UIKit
import CoreData

class FoodListVC: UIViewController {
    
    // MARK: Segues
    
    private enum Segue {
        static let FoodEditorAdd = "FoodEditorAdd"
        static let FoodEditorEdit = "FoodEditorEdit"
    }

    // MARK: Properties
    
    @IBOutlet weak var foodItemLabel: UILabel!
    @IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var alternativesLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var foodItems: [FoodItem]? {
        didSet {
            configureView()
        }
    }
    
    private let coreDataManager = CoreDataManager(modelName: "FoodItems")
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupNotificationHandling()
        
        let foodDataLoader = FoodDataLoader()
        foodDataLoader.loadDefaultFoods(into: coreDataManager.managedObjectContext)
    }
    
    // MARK: Setup

    private func setupView() {
        setupTableView()
    }
    
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    private func setupNotificationHandling() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(managedObjectContextObjectsDidChange(_:)),
                                               name: Notification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: coreDataManager.managedObjectContext)
    }
    
    // MARK: Configuration
    
    func configureView() {
        tableView.reloadData()
    }
    
    // MARK: Convenience
    
    private func fetchFoodItems() {
        let fetchRequest: NSFetchRequest<FoodItem> = FoodItem.fetchRequest()
        coreDataManager.managedObjectContext.performAndWait {
            do {
                let foodItems = try fetchRequest.execute()
                self.foodItems = foodItems
            } catch {
                print("Unable to execute FoodItem Fetch Request")
            }
        }
    }
    
    @objc private func managedObjectContextObjectsDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        var foodItemsDidChange = false
        
        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject> {
            for insert in inserts {
                if let foodItem = insert as? FoodItem {
                    self.foodItems?.append(foodItem)
                    foodItemsDidChange = true
                }
            }
        }
        
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
            for update in updates {
                if let _ = update as? FoodItem {
                    foodItemsDidChange = true
                }
            }
        }
        
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject> {
            for delete in deletes {
                if let foodItem = delete as? FoodItem {
                    if let index = foodItems?.index(of: foodItem) {
                        foodItems?.remove(at: index)
                        foodItemsDidChange = true
                    }
                }
            }
        }
        
        if foodItemsDidChange {
            
        }
    }

    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case Segue.FoodEditorEdit:
            guard let destination = segue.destination as? FoodEditorVC else { return }
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            destination.foodItem = foodItems?[indexPath.row]
        default:
            break
        }
    }
}

// MARK:- UITableViewDelegate, UITableViewDataSource

extension FoodListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let foodItem = foodItems?[indexPath.row] else { fatalError("FoodListVC-Unexpected IndexPath") }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FoodItemCell.reuseIdentifier, for: indexPath) as? FoodItemCell else {
            fatalError("FoodListVC-Unexpected IndexPath")
        }
        cell.configureCell(with: foodItem.name!, content: "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        guard let foodItem = foodItems?[indexPath.row] else { fatalError("FoodListVC-Unexpected IndexPath") }
        coreDataManager.managedObjectContext.delete(foodItem)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Segue.FoodEditorEdit, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodItems?.count ?? 0
    }
}

