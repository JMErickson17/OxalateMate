//
//  FoodDataManager.swift
//  OxalateMate
//
//  Created by Justin Erickson on 2/8/18.
//  Copyright © 2018 Justin Erickson. All rights reserved.
//

import CoreData
import UIKit

final class FoodDataManager {
    
    // MARK: Properties
    
    private let coreDataManager: CoreDataManager
    private let itemManager: FilterableItemManager<FoodItem>
    
    // MARK: Initialization
    
    init(coreDataManager: CoreDataManager, itemManager: FilterableItemManager<FoodItem>) {
        self.coreDataManager = coreDataManager
        self.itemManager = itemManager
        itemManager.delegate = self
        setupNotificationHandling()
        fetchFoodItems()
        checkFirstLaunch()
    }
    
    // MARK: Configuration
    
    private func setupNotificationHandling() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(managedObjectContextObjectsDidChange(_:)),
                                               name: Notification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: coreDataManager.managedObjectContext)
    }
    
    private func checkFirstLaunch() {
        if UIApplication.isFirstLaunch() {
            loadDefaultFoodItems()
        }
    }
    
    // MARK: Public API
    
    var afterFoodItemsUpdate: (() -> Void)?
    
    var firstFoodItem: FoodItem? {
        return itemManager.items.first
    }
    
    var itemCount: Int {
        return itemManager.items.count
    }
    
    func resetToDefaultFoodItems() {
        self.removeAllFoodItems()
        self.loadDefaultFoodItems()
        afterFoodItemsUpdate?()
    }
    
    func updateFoodItems() {
        fetchFoodItems()
    }
    
    func foodItem(for indexPath: IndexPath) -> FoodItem {
        return itemManager.items[indexPath.row]
    }
    
    func addFoodItem(name: String, content: Int, alternatives: String) {
        let newItem = FoodItem(context: coreDataManager.managedObjectContext)
        newItem.name = name
        newItem.content = Int16(content)
        newItem.alternatives = alternatives
        
        coreDataManager.managedObjectContext.processPendingChanges()
    }
    
    func delete(_ foodItem: FoodItem) {
        coreDataManager.managedObjectContext.delete(foodItem)
    }
    
    func filterFoodItems(for text: String) {
        guard text != "" else { itemManager.resetFilters(); return }
        itemManager.filterItems { $0.nameString.lowercased().contains(text.lowercased()) }
    }
    
    
    // MARK: Core Data
    
    private func fetchFoodItems() {
        let fetchRequest: NSFetchRequest<FoodItem> = FoodItem.fetchRequest()
        coreDataManager.managedObjectContext.performAndWait {
            do {
                let foodItems = try fetchRequest.execute()
                itemManager.set(foodItems)
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
                    itemManager.add(foodItem)
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
                    itemManager.remove(foodItem)
                    foodItemsDidChange = true
                }
            }
        }
        
        if foodItemsDidChange {
            afterFoodItemsUpdate?()
        }
    }
    
    private func removeAllFoodItems() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FoodItem.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try coreDataManager.managedObjectContext.execute(deleteRequest)
            itemManager.removeAll()
            afterFoodItemsUpdate?()
        } catch {
            print("FoodDataManager-Could not delete all food items")
        }
    }
    
    private func loadDefaultFoodItems() {
        let foodDataLoader = FoodDataLoader()
        foodDataLoader.loadDefaultFoods(into: coreDataManager.managedObjectContext)
    }
}

// MARK:- FilterableItemManagerDelegate

extension FoodDataManager: FilterableItemManagerDelegate {
    func filterableItemManagerDidUpdateItems<T>(_ filterableItemManager: FilterableItemManager<T>) {
        afterFoodItemsUpdate?()
    }
}
