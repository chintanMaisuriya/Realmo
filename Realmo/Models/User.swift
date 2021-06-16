//
//  User.swift
//  Realmo
//
//  Created by Chintan Maisuriya on 22/09/20.
//  Copyright © 2020 Chintan Maisuriya. All rights reserved.
//

import Foundation
import RealmSwift


class User: Object
{
    @objc dynamic var name      : String = ""
    @objc dynamic var email     : String = ""
    @objc dynamic var gender    : String = ""
    @objc dynamic var birthDate : Date? = nil
    @objc dynamic var createdAt : Date? = nil
    @objc dynamic var updatedAt : Date? = nil
    
    
    convenience init(strName: String, strEmail: String, strGender: String, birhtDate: Date?, createdDate: Date?, updatedDate: Date?)
    {
        self.init()
        
        self.name       = strName
        self.email      = strEmail
        self.gender     = strGender
        self.birthDate  = birhtDate ?? nil
        self.createdAt  = createdDate ?? self.createdAt
        self.updatedAt  = updatedDate ?? self.updatedAt
    }
    
    
    func getDateInString(isDOB: Bool = false) -> String
    {
        guard let date = isDOB ? birthDate : updatedAt else { return "" }
        
        let locale              = Locale(identifier: "en_GB")
        let formatter           = DateFormatter()
        formatter.dateStyle     = .medium
        formatter.locale        = locale
        formatter.dateFormat    = isDOB ? "dd/MM/yyyy" : "dd MMM, yyyy - hh:mm a"

        return (formatter.string(from: date))
    }
}
