//
//  AlertService.swift
//  Realmo
//
//  Created by Chintan Maisuriya on 21/09/20.
//  Copyright © 2020 Chintan Maisuriya. All rights reserved.
//

import UIKit

class AlertService
{
    private init() {}
    
    static func addTodoAlert(in vc: UIViewController, completion: @escaping (String) -> Void)
    {
        let alert = UIAlertController(title: "Add To-Do Task", message: nil, preferredStyle: .alert)
       
        alert.addTextField { (textField) in
            textField.placeholder   = "Enter here ..."
            textField.tintColor     = UIColor(named: "Color1")
        }
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            guard let str = alert.textFields?.first?.text else { return }
            completion(str)
        }
        
        let caction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(action)
        alert.addAction(caction)

        vc.present(alert, animated: true)
    }
    
    
    static func updateTodoAlert(in vc: UIViewController, todoInfo: ToDo, completion: @escaping (String) -> Void)
    {
        let alert = UIAlertController(title: "Update To-Do Task", message: nil, preferredStyle: .alert)
       
        alert.addTextField { (textField) in
            textField.placeholder   = "Enter here ..."
            textField.text          = todoInfo.todoDescription
            textField.tintColor     = UIColor(named: "Color1")
        }
        
        let action = UIAlertAction(title: "Update", style: .default) { (action) in
            guard let str = alert.textFields?.first?.text else { return }
            completion(str)
        }
        
        let caction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(action)
        alert.addAction(caction)

        vc.present(alert, animated: true)
    }
    
    static func deleteAlert(in vc: UIViewController, alertMessage: String = "Sure you want to delete?", completion: @escaping (Bool) -> Void)
    {
        let alert = UIAlertController(title: "Delete!", message: alertMessage, preferredStyle: .alert)
         
         let action = UIAlertAction(title: "Delete", style: .default) { (action) in
             completion(true)
         }
         
         let caction = UIAlertAction(title: "Cancel", style: .cancel)

         alert.addAction(action)
         alert.addAction(caction)

         vc.present(alert, animated: true)
    }
    
}
