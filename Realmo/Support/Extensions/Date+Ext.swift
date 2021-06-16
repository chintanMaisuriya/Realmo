//
//  Date+Ext.swift
//  Realmo
//
//  Created by Chintan Maisuriya on 16/06/21.
//  Copyright © 2021 Chintan Maisuriya. All rights reserved.
//

import Foundation


extension Date
{
    var isPastDate: Bool {
        return self < Date()
    }
    
    var isFutureDate: Bool {
        return self > Date()
    }
    
    var isDateInToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    var isDateInYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
}
