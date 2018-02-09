//
//  FilterableItemManagerDelegate.swift
//  OxalateMate
//
//  Created by Justin Erickson on 2/8/18.
//  Copyright © 2018 Justin Erickson. All rights reserved.
//

import Foundation

protocol FilterableItemManagerDelegate: class {
    func filterableItemManagerDidUpdateItems<T>(_ filterableItemManager: FilterableItemManager<T>)
}
