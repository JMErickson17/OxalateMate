//
//  FoodItem.swift
//  OxalateMate
//
//  Created by Justin Erickson on 2/8/18.
//  Copyright © 2018 Justin Erickson. All rights reserved.
//

import Foundation

extension FoodItem {
    
    var nameString: String {
        return self.name ?? ""
    }
    
    var alternativesString: String {
        return self.alternatives ?? ""
    }
    
    var contentString: String {
        switch self.content {
        case 0: return "Low"
        case 1: return "Medium"
        case 2: return "High"
        default: return ""
        }
    }
}
