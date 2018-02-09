//
//  RadioButtons.swift
//  OxalateMate
//
//  Created by Justin Erickson on 2/8/18.
//  Copyright © 2018 Justin Erickson. All rights reserved.
//

import UIKit

protocol RadioSelectable: class {
    func select()
    func deSelect()
}

final class RadioButtons<T: RadioSelectable> {
    
    // MARK: Properties
    
    private(set) var buttons: [T]
    private(set) var selectedIndex: Int? {
        didSet {
            configureButtons(for: selectedIndex)
        }
    }
    
    // MARK: Initialization
    
    init(buttons: [T]) {
        self.buttons = buttons
        deSelectAllButtons()
    }
    
    // MARK: Configuration
    
    private func configureButtons(for selection: Int?) {
        deSelectAllButtons()
        
        guard let selection = selection else { return }
        guard selection < buttons.count else { return }
        buttons[selection].select()
    }
    
    private func deSelectAllButtons() {
        buttons.forEach { button in
            button.deSelect()
        }
    }
    
    // MARK: Convenience
    
    func selectButton(at index: Int) {
        self.selectedIndex = index
    }
}
