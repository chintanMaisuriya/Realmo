//
//  UserListVC.swift
//  Realmo
//
//  Created by Chintan Maisuriya on 22/09/20.
//  Copyright © 2020 Chintan Maisuriya. All rights reserved.
//

import UIKit
import RealmSwift

enum FilterState: String, CaseIterable {
    case all    = "Show All"
    case male   = "Male Only"
    case female = "Female Only"
}


class UserListVC: UIViewController
{

    //MARK: -
    
    private let realm = RealmService.shared.getDefaultInstance()
    private var users: Results<User>? = nil
    private var realmNotificationToken: NotificationToken?
    
    private var selectedFilterState : FilterState = .all
    private var isSearchActive      : Bool = false


    //MARK: -

    @IBOutlet weak var tblUsersOutlet  : UITableView!
    @IBOutlet weak var btnClearAllOutlet    : UIBarButtonItem!
    @IBOutlet weak var btnFilterOutlet : UIBarButtonItem!
    
    
    //MARK: -

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tblUsersOutlet.tableFooterView = UIView()
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.getToUsers()
    }
    
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        realmNotificationToken?.invalidate()
    }
    
    //MARK: -
    
    @IBAction func btnClearAllAction(_ sender: UIBarButtonItem)
    {
        AlertService.deleteAlert(in: self, alertMessage: "Sure you want to clear local database completly?") { (status) in
            guard status else { return }
            RealmService.shared.deleteAllFromRealm()
        }
    }
    
    
    @IBAction func btnFilterAction(_ sender: Any)
    {
        self.displayFilterOptions()
    }
    
    
    @IBAction func btnAddAction(_ sender: UIBarButtonItem)
    {
        self.navToAddUser()
    }
    

    /*
    // MARK: - Navigation
    */

}



//MARK: -

extension UserListVC: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let users = self.users, users.count > 0
        {
            tableView.removeNoDataLabel()
            return users.count
        }
        else
        {
            tableView.showNoDataLabel("You can add user by clicking on '+' button above", isScrollable: false)
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let users = self.users, users.count > 0 else { return UITableViewCell() }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "userTVCell") as? userTVCell else { return UITableViewCell() }
        
        cell.configure(userInfo: users[indexPath.row])
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        guard let users = self.users, users.count > 0 else { return 0 }
        return (users.count > 0) ? 114 : 0
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        guard let users = self.users, users.count > 0 else { return false }
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete { tableView.deleteRows(at: [indexPath], with: .automatic) }
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        guard let users = self.users, users.count > 0 else { return nil }

        let deleteAction = UIContextualAction(style: .normal, title: nil) { _, _, complete in
            
            AlertService.deleteAlert(in: self, alertMessage: "Sure you want to delete this user?") { (status) in
                guard status else { return }
                RealmService.shared.deleteFromRealm(users[indexPath.row])
            }
            
            complete(true)
        }
        
        
        let editAction = UIContextualAction(style: .normal, title: nil) { _, _, complete in
            self.navToAddUser(isForEdit: true, userInfo: users[indexPath.row])
            complete(true)
        }
        
        // here set your image and background color
        let sfconfiguration = UIImage.SymbolConfiguration(pointSize: 34, weight: .semibold, scale: .large)

        deleteAction.image = UIImage(systemName: "trash.circle.fill")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal).withConfiguration(sfconfiguration)
        deleteAction.backgroundColor = .secondarySystemBackground
        
        
        editAction.image = UIImage(systemName: "pencil.circle.fill")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal).withConfiguration(sfconfiguration)
        editAction.backgroundColor = .secondarySystemBackground
        
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}


//MARK: -

extension UserListVC: UISearchResultsUpdating, UISearchBarDelegate
{
    func updateSearchResults(for searchController: UISearchController)
    {
        navigationController!.navigationBar.sizeToFit()

        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            self.isSearchActive = false
            self.reloadToUserList(isCalledWithSearch: true, searchedText: nil)
            return
        }
        
        self.isSearchActive = true
        self.reloadToUserList(isCalledWithSearch: true, searchedText: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        self.isSearchActive = false
        self.users = nil
    }
    
}


//MARK: -

extension UserListVC
{
    private func configureSearchBar()
    {
        let searchController                                    = UISearchController()
        searchController.searchResultsUpdater                   = self
        searchController.searchBar.delegate                     = self
        searchController.obscuresBackgroundDuringPresentation   = false
        searchController.searchBar.placeholder                  = "Search for user"
        searchController.searchBar.tintColor                    = UIColor(named: "Color1")
        
        navigationItem.searchController                         = searchController
    }
    
    
    private func setSearchBarVisibility(isCalledFromActiveSearch: Bool = false)
    {
        guard !isCalledFromActiveSearch else { return }
        
        if ((self.users?.count ?? 0) >= 2)
        {
            self.configureSearchBar()
        }
        else
        {
            navigationItem.searchController = nil
        }
        
        navigationItem.hidesSearchBarWhenScrolling  = false
        navigationController!.navigationBar.sizeToFit()
    }
    
    
    func getToUsers()
    {
        self.reloadToUserList()

        realmNotificationToken = realm.observe { (notification, realm) in
            self.setClearallVisibility()
            self.setFilterVisibility()
            self.setSearchBarVisibility()
            DispatchQueue.main.async { self.tblUsersOutlet.reloadData() }
        }
    }
    
    
    func displayFilterOptions()
    {
        let actionsheet = UIAlertController(title: "", message: "Would you like to filter the users by?", preferredStyle: .actionSheet)
        
        for optn in FilterState.allCases
        {
            actionsheet.addAction(UIAlertAction(title: optn.rawValue, style: .default , handler:{ (action) in
                
                switch action.title ?? "" {
                    
                case FilterState.all.rawValue:
                    self.selectedFilterState = .all
                    self.reloadToUserList()
                    break
                    
                case FilterState.male.rawValue:
                    self.selectedFilterState = .male
                    self.reloadToUserList()
                    break
                    
                case FilterState.female.rawValue:
                    self.selectedFilterState = .female
                    self.reloadToUserList()
                    break
                    
                default:
                    break
                }
            }))
        }
        
        actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(actionsheet, animated: true, completion: nil)
    }
    
    
    func reloadToUserList(isCalledWithSearch: Bool = false, searchedText: String? = nil)
    {
        if let searchedText = searchedText, isCalledWithSearch
        {
            self.users = nil
            self.selectedFilterState = .all
            
            let nPredicate  = NSPredicate(format: "name CONTAINS[c] %@", searchedText.lowercased())
            let ePredicate  = NSPredicate(format: "email CONTAINS[c] %@", searchedText.lowercased())
            let predicate   = NSCompoundPredicate(type: .or, subpredicates: [nPredicate, ePredicate])

            self.users = realm.objects(User.self).filter(predicate)
        }
        else
        {
            if self.selectedFilterState == .all
            {
                users = realm.objects(User.self).sorted(byKeyPath: "updatedAt", ascending: false)
            }
            else
            {
                let predicate = NSPredicate(format: "gender = %@", (self.selectedFilterState.rawValue == "Male Only") ? "Male" : "Female")
                users = realm.objects(User.self).sorted(byKeyPath: "updatedAt", ascending: false).filter(predicate)
            }
        }
        
    
        self.setClearallVisibility()
        self.setFilterVisibility()
        self.setSearchBarVisibility(isCalledFromActiveSearch: isCalledWithSearch)

        DispatchQueue.main.async { self.tblUsersOutlet.reloadData() }
    }
    
    
    func setFilterVisibility()
    {
        let users = realm.objects(User.self).sorted(byKeyPath: "updatedAt", ascending: false)
        
        UIView.animate(withDuration: 0.4) {
            self.btnFilterOutlet.isHidden = (users.count > 0) ? false : true
        }
    }
    
    
    func setClearallVisibility()
    {
        UIView.animate(withDuration: 0.4) {
            self.btnClearAllOutlet.isHidden = RealmService.shared.isRealmDBEmpty() ? true : false
        }
    }
    
    
    func navToAddUser(isForEdit: Bool = false, userInfo: User? = nil)
    {
        guard let vc = self.storyboard?.instantiateViewController(identifier: "AddUserVC") as? AddUserVC else { return }
        vc.isComeForEditUser    = isForEdit
        vc.userInfoToEdit       = userInfo
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
