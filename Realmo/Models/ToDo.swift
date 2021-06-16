//
//  ToDo.swift
//  Realmo
//
//  Created by Chintan Maisuriya on 21/09/20.
//  Copyright © 2020 Chintan Maisuriya. All rights reserved.
//

import Foundation
import RealmSwift


class ToDo: Object
{
    @objc dynamic var todoDescription: String = ""
    @objc dynamic var isCompleted   : Bool  = false
    @objc dynamic var createdAt     : Date? = nil
    @objc dynamic var updatedAt     : Date? = nil
    
    
    convenience init(strDescription: String, isCompleted: Bool, createdDate: Date?, updatedDate: Date?)
    {
        self.init()
        self.todoDescription = strDescription
        self.isCompleted = isCompleted
        self.createdAt = createdDate ?? self.createdAt
        self.updatedAt = updatedDate ?? self.updatedAt
    }
    
    
    func getDateInString() -> String
    {
        guard let date = updatedAt else { return "" }
        
        let locale              = Locale(identifier: "en_GB")
        let formatter           = DateFormatter()
        formatter.dateStyle     = .medium
        formatter.locale        = locale
        formatter.dateFormat    = "dd MMM, yyyy - hh:mm a"

        return (formatter.string(from: date))
    }
}
