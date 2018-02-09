//
//  OxalateRadioButton.swift
//  OxalateMate
//
//  Created by Justin Erickson on 2/8/18.
//  Copyright © 2018 Justin Erickson. All rights reserved.
//

import UIKit

class OxalateRadioButton: UIButton {

}

extension OxalateRadioButton: RadioSelectable {
    func select() {
        self.layer.opacity = 1.0
    }
    
    func deSelect() {
        self.layer.opacity = 0.4
    }
    
    
}
