//
//  FoodDataLoader.swift
//  OxalateMate
//
//  Created by Justin Erickson on 2/8/18.
//  Copyright © 2018 Justin Erickson. All rights reserved.
//

import CoreData

struct FoodDataLoader {
    
    typealias FoodArray = [[String: Any]]
    
    private let fileName = "FoodData"
    
    func loadDefaultFoods(into context: NSManagedObjectContext) {
        guard let foodDataURL = Bundle.main.url(forResource: fileName, withExtension: "json") else { fatalError("FoodDataLoader-Could not find default food file") }
        do {
            let data = try Data(contentsOf: foodDataURL)
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            if let jsonArray = json as? FoodArray {
                let _ = jsonArray.map { element -> FoodItem in
                    let foodItem = FoodItem(context: context)
                    foodItem.name = element["name"] as? String
                    foodItem.content = element["content"] as! Int16
                    foodItem.alternatives = element["alternatives"] as? String
                    return foodItem
                }
                
                try context.save()
            }
        } catch {
            fatalError("FoodDataLoader-Could not make Default Food Data")
        }
    }
}
