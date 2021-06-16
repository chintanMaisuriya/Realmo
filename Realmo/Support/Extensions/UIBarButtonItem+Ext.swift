//
//  UIBarButtonItem+Ext.swift
//  Realmo
//
//  Created by Chintan Maisuriya on 22/09/20.
//  Copyright © 2020 Chintan Maisuriya. All rights reserved.
//

import UIKit

extension UIBarButtonItem
{
    var isHidden: Bool {
        get {
            return !isEnabled && tintColor == .clear
        }
        set {
            tintColor = newValue ? .clear : UIColor(named: "Color1")
            isEnabled = !newValue
        }
    }
}
