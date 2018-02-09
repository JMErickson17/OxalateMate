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
    }
    
    private enum Constants {
        static let AlternativesPrefix = "Alternatives: "
        static let SearchBarPlaceholder = "Search Foods"
    }

    // MARK: Properties
    
    @IBOutlet weak var foodItemLabel: UILabel!
    @IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var alternativesLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    private let searchController = UISearchController(searchResultsController: nil)
    private let contentImages = [#imageLiteral(resourceName: "LowOxalate"), #imageLiteral(resourceName: "MediumOxalate"), #imageLiteral(resourceName: "HighOxalate")]
    
    private lazy var foodDataManager: FoodDataManager = {
        let coreDataManager = CoreDataManager(modelName: "FoodItems")
        let foodItemManager: FilterableItemManager<FoodItem> = FilterableItemManager(items: [FoodItem]())
        let foodDataManager = FoodDataManager(coreDataManager: coreDataManager, itemManager: foodItemManager)
        foodDataManager.afterFoodItemsUpdate = {
            self.updateViewForNewFoodItems()
        }
        return foodDataManager
    }()
    
    private lazy var tableViewEditAction: UITableViewRowAction = {
        let action = UITableViewRowAction(style: .normal, title: "Edit", handler: { action, indexPath in
            let foodItem = self.foodDataManager.foodItem(for: indexPath)
            self.presentFoodEditor(with: foodItem)
        })
        action.backgroundColor = UIColor.green
        return action
    }()
    
    private lazy var tableViewDeleteAction: UITableViewRowAction = {
        return UITableViewRowAction(style: .destructive, title: "Delete", handler: { action, indexPath in
            self.tableView.beginUpdates()
            let foodItem = self.foodDataManager.foodItem(for: indexPath)
            self.foodDataManager.delete(foodItem)
            self.tableView.endUpdates()
        })
    }()
    
    private lazy var resetAlertController: UIAlertController = {
        let alert = UIAlertController(title: "Reset All Foods?", message: "Are you sure you want to reset all food items?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { action in
            self.foodDataManager.resetToDefaultFoodItems()
        }))
        return alert
    }()
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    // MARK: Setup

    private func setupView() {
        setupTableView()

        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = Constants.SearchBarPlaceholder
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.setTextColor(color: UIColor.white)
        searchController.searchBar.barStyle = .blackTranslucent
        definesPresentationContext = true
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
        
        if let initialFoodItem = foodDataManager.firstFoodItem {
            self.configureView(for: initialFoodItem)
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: Configuration
    
    func updateViewForNewFoodItems() {
        self.tableView.reloadData()
    }
    
    func configureView(for foodItem: FoodItem) {
        self.foodItemLabel.text = foodItem.name
        self.contentImage.image = contentImages[Int(foodItem.content)]
        self.alternativesLabel.text = Constants.AlternativesPrefix + foodItem.alternativesString
    }
    
    @IBAction func resetButtonWasTapped(_ sender: Any) {
        present(resetAlertController, animated: true) {
            self.updateViewForNewFoodItems()
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case Segue.FoodEditorAdd:
            if let destination = segue.destination as? FoodEditorVC {
                destination.foodDataManager = foodDataManager
            }
        default:
            break
        }
    }
    
    private func presentFoodEditor(with foodItem: FoodItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let editorVC = storyboard.instantiateViewController(withIdentifier: "FoodEditorVC") as? FoodEditorVC else { return }
        editorVC.loadView()
        editorVC.foodItem = foodItem
        navigationController?.pushViewController(editorVC, animated: true)
    }
}

// MARK:- UITableViewDelegate, UITableViewDataSource

extension FoodListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FoodItemCell.reuseIdentifier, for: indexPath) as? FoodItemCell else {
            fatalError("FoodListVC-Unexpected IndexPath")
        }
        let foodItem = foodDataManager.foodItem(for: indexPath)
        cell.configureCell(with: foodItem.nameString, content: foodItem.contentString)
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [tableViewEditAction, tableViewDeleteAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let foodItem = foodDataManager.foodItem(for: indexPath)
        self.configureView(for: foodItem)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodDataManager.itemCount
    }
}

// MARK:- UISearchResultsUpdating

extension FoodListVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            foodDataManager.filterFoodItems(for: searchText)
        }
    }
}



