//
//  UIApplication+FirstLaunch.swift
//  OxalateMate
//
//  Created by Justin Erickson on 2/8/18.
//  Copyright © 2018 Justin Erickson. All rights reserved.
//

import UIKit

private var isFirstLaunchFlag: Bool = true


extension UIApplication {
    
    static func isFirstLaunch() -> Bool {
        UserDefaults.standard.set(isFirstLaunchFlag, forKey: "isFirstLaunchFlag")
        if isFirstLaunchFlag {
            UserDefaults.standard.set(false, forKey: "isFirstLaunchFlag")
            return true
        }
        return false
    }
}

