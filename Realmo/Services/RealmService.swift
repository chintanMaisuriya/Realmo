//
//  RealmService.swift
//  Realmo
//
//  Created by Chintan Maisuriya on 21/09/20.
//  Copyright © 2020 Chintan Maisuriya. All rights reserved.
//

import UIKit
import RealmSwift


class RealmService
{
    static let shared = RealmService()
    private var realm: Realm

    
    private init()
    {
        realm = try! Realm()
    }
    
    
    func configure()
    {
        var config = Realm.Configuration()

        // Use the default directory, but replace the filename with the username
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(UIApplication.shared.getAppName()).realm")

        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
    
    func getDefaultInstance() -> Realm
    {
        return realm
    }
    
    func addToRealm<T: Object>(_ object: T)
    {
        do{
            try realm.write {
                realm.add(object)
            }
        } catch {
            postErrorNotification(error)
        }
    }
    
    
    func updateOnRealm<T: Object>(_ object: T, with dictionary: [String: Any])
    {
        do{
            try realm.write {
                
                for (key, value) in dictionary
                {
                    object.setValue(value, forKey: key)
                }
            }
        } catch {
            postErrorNotification(error)
        }
    }
    
    
    func deleteFromRealm<T: Object>(_ object: T)
    {
        do{
            try realm.write {
               realm.delete(object)
            }                
        } catch {
            postErrorNotification(error)
        }
    }
    
    
    func deleteAllFromRealm()
    {
        do{
            try realm.write {
               realm.deleteAll()
            }
        } catch {
            postErrorNotification(error)
        }
    }
    
    
    func isRealmDBEmpty() -> Bool
    {
        return realm.isEmpty
    }
    
    
    func postErrorNotification(_ error: Error)
    {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RealmError"), object: error)
    }
    
    
    func observeRealError(in vc: UIViewController, completion: @escaping(Error?) -> Void)
    {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "RealmError"), object: nil, queue: nil) { (notification) in
            completion(notification.object as? Error)
        }
    }
    
    
    func stopObservingErrors(in vc: UIViewController)
    {
        NotificationCenter.default.removeObserver(vc, name: NSNotification.Name(rawValue: "RealmError"), object: nil)
    }
    
}


