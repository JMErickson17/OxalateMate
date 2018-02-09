//
//  FoodItemManager.swift
//  OxalateMate
//
//  Created by Justin Erickson on 2/8/18.
//  Copyright © 2018 Justin Erickson. All rights reserved.
//

import Foundation

final class FilterableItemManager<T: Equatable> {
    
    // MARK: Properties
    
    weak var delegate: FilterableItemManagerDelegate?
    
    private var filterPredicate: ((T) -> Bool)? {
        didSet { delegate?.filterableItemManagerDidUpdateItems(self) }
    }
    
    private var allItems: [T] {
        didSet { delegate?.filterableItemManagerDidUpdateItems(self) }
    }
    
    var items: [T] {
        get {
            if let predicate = filterPredicate {
                return allItems.filter(predicate)
            }
            return allItems
        }
        set {
            allItems = newValue
        }
    }
    
    init(items: [T]) {
        self.allItems = items
    }
    
    // MARK: Convenience
    
    func set(_ items: [T]) {
        self.items = items
        filterPredicate = nil
    }
    
    func add(_ item: T) {
        self.allItems.append(item)
    }
    
    func remove(_ item: T) {
        if let index = allItems.index(of: item) {
            allItems.remove(at: index)
        }
    }
    
    func removeAll() {
        items.removeAll()
        filterPredicate = nil
    }
    
    func filterItems(_ filterPredicate: @escaping (T) -> Bool) {
        self.filterPredicate = filterPredicate
    }
    
    func resetFilters() {
        filterPredicate = nil
    }
}
