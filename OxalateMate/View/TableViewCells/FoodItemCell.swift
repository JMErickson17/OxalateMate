//
//  FoodItemCell.swift
//  OxalateMate
//
//  Created by Justin Erickson on 2/8/18.
//  Copyright © 2018 Justin Erickson. All rights reserved.
//

import UIKit

class FoodItemCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!

    // MARK: Convenience
    
    func configureCell(with name: String, content: String) {
        self.foodNameLabel.text = name
        self.contentLabel.text = content
    }

}
