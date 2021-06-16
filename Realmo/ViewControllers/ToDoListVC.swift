//
//  ToDoListVC.swift
//  Realmo
//
//  Created by Chintan Maisuriya on 22/09/20.
//  Copyright © 2020 Chintan Maisuriya. All rights reserved.
//

import UIKit
import RealmSwift


enum SortingState: String, CaseIterable {
    case ascDate            = "Date (Ascending)"
    case desDate            = "Date (Descending)"
    case completedTasks     = "Completed Tasks"
    case pendingTasks       = "Pending Tasks"

}



class ToDoListVC: UIViewController
{

    //MARK: -
    
    private let realm = RealmService.shared.getDefaultInstance()
    private var toDos: Results<ToDo>? = nil
    private var toDosToDisplay: Results<ToDo>? = nil
    private var realmNotificationToken: NotificationToken?
    
    private var selectedSortingState    : SortingState = .desDate
    private var isSearchActive          : Bool = false
    
    //MARK: -

    @IBOutlet weak var tblToDosOutlet       : UITableView!
    @IBOutlet weak var btnClearAllOutlet    : UIBarButtonItem!
    @IBOutlet weak var btnSortOutlet        : UIBarButtonItem!
    
    
    //MARK: -
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tblToDosOutlet.tableFooterView = UIView()
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.getToDos()
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
    
    
    @IBAction func btnSortAction(_ sender: Any)
    {
        self.displaySortingOptions()
    }
    
    
    @IBAction func btnAddAction(_ sender: UIBarButtonItem)
    {
        AlertService.addTodoAlert(in: self) { (str) in
            let todo = ToDo(strDescription: str, isCompleted: false, createdDate: Date(), updatedDate: Date())
            RealmService.shared.addToRealm(todo)
        }
    }
}


//MARK: -

extension ToDoListVC: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let todos = self.toDosToDisplay, todos.count > 0
        {
            tableView.removeNoDataLabel()
            return todos.count
        }
        else
        {
            let placeholder = self.isSearchActive ? "No to-do tasks found!" : ((self.toDos?.isEmpty ?? true) ? "You can add to-do task by clicking on '+' button above" : "Please adjust your sorting options to get desired tasks")
            tableView.showNoDataLabel(placeholder, isScrollable: false)
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let todos = self.toDosToDisplay, todos.count > 0 else { return UITableViewCell() }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "todoTVCell") as? todoTVCell else { return UITableViewCell() }
        cell.configure(todoInfo: todos[indexPath.row])
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        guard let todos = self.toDosToDisplay, todos.count > 0 else { return false }
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete { tableView.deleteRows(at: [indexPath], with: .automatic) }
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        guard let todos = self.toDosToDisplay, todos.count > 0 else { return nil }

        let deleteAction = UIContextualAction(style: .normal, title: nil) { _, _, complete in
            
            AlertService.deleteAlert(in: self, alertMessage: "Sure you want to delete this to-do task?") { (status) in
                guard status else { return }
                RealmService.shared.deleteFromRealm(todos[indexPath.row])
            }
            
            complete(true)
        }
        
        
        let taskDoCompleteAction = UIContextualAction(style: .normal, title: nil) { _, _, complete in
            let task = todos[indexPath.row]
            let dix: [String : Any] = ["todoDescription" : task.todoDescription, "isCompleted": !task.isCompleted]
            RealmService.shared.updateOnRealm(todos[indexPath.row], with: dix)
        }
        
        
        let editAction = UIContextualAction(style: .normal, title: nil) { _, _, complete in
            
            AlertService.updateTodoAlert(in: self, todoInfo: todos[indexPath.row]) { (str) in
                let dix: [String : Any] = ["todoDescription" : str, "updatedAt" : Date()]
                RealmService.shared.updateOnRealm(todos[indexPath.row], with: dix)
            }
            
            complete(true)
        }
        
        // here set your image and background color
        let sfconfiguration = UIImage.SymbolConfiguration(pointSize: 34, weight: .semibold, scale: .large)

        deleteAction.image = UIImage(systemName: "trash.circle.fill")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal).withConfiguration(sfconfiguration)
        deleteAction.backgroundColor = .secondarySystemBackground
        
        let taskImage = todos[indexPath.row].isCompleted ? UIImage(systemName: "xmark.circle.fill")?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal) : UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
        taskDoCompleteAction.image = taskImage?.withConfiguration(sfconfiguration)
        taskDoCompleteAction.backgroundColor = .secondarySystemBackground

        
        editAction.image = UIImage(systemName: "pencil.circle.fill")?.withTintColor(.systemOrange, renderingMode: .alwaysOriginal).withConfiguration(sfconfiguration)
        editAction.backgroundColor = .secondarySystemBackground
        
        let actions = (todos[indexPath.row].isCompleted) ? [deleteAction, taskDoCompleteAction] : [deleteAction, taskDoCompleteAction, editAction]
        let configuration = UISwipeActionsConfiguration(actions: actions)
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        guard let todos = self.toDosToDisplay, todos.count > 0 else { return 0 }
        return (todos.count > 0) ? UITableView.automaticDimension : 0
    }
}


//MARK: -

extension ToDoListVC: UISearchResultsUpdating, UISearchBarDelegate
{
    func updateSearchResults(for searchController: UISearchController)
    {
        navigationController!.navigationBar.sizeToFit()

        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            self.isSearchActive = false
            self.reloadToDoList(isCalledWithSearch: true, searchedText: nil)
            return
        }
        
        self.isSearchActive = true
        self.reloadToDoList(isCalledWithSearch: true, searchedText: searchText)
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        self.isSearchActive = false
        self.toDosToDisplay = nil
    }
}


//MARK: -

extension ToDoListVC
{
    private func configureSearchBar()
    {
        let searchController                                    = UISearchController()
        searchController.searchResultsUpdater                   = self
        searchController.searchBar.delegate                     = self
        searchController.obscuresBackgroundDuringPresentation   = false
        searchController.searchBar.placeholder                  = "Search for to-do task"
        searchController.searchBar.tintColor                    = UIColor(named: "Color1")
        
        navigationItem.searchController                         = searchController
    }
    
    
    private func setSearchBarVisibility(isCalledFromActiveSearch: Bool = false)
    {
        guard !isCalledFromActiveSearch else { return }
        
        if ((self.toDosToDisplay?.count ?? 0) >= 2)
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
    
    
    private func getToDos()
    {
        self.reloadToDoList()

        realmNotificationToken = realm.observe { (notification, realm) in
            self.setClearallVisibility()
            self.setSortingVisibility()
            self.setSearchBarVisibility()
            DispatchQueue.main.async { self.tblToDosOutlet.reloadData() }
        }
    }
    
    
    private func displaySortingOptions()
    {
        let actionsheet = UIAlertController(title: "", message: "Would you like to sort by?", preferredStyle: .actionSheet)
        
        for optn in SortingState.allCases {
            
            actionsheet.addAction(UIAlertAction(title: optn.rawValue, style: .default , handler:{ (action) in
                
                switch action.title ?? "" {
                
                case SortingState.desDate.rawValue:
                    self.selectedSortingState = .desDate
                    
                case SortingState.ascDate.rawValue:
                    self.selectedSortingState = .ascDate
                    
                case SortingState.completedTasks.rawValue:
                    self.selectedSortingState = .completedTasks
                    
                case SortingState.pendingTasks.rawValue:
                    self.selectedSortingState = .pendingTasks
                
                default: break
                }
                
                self.reloadToDoList()

            }))
        }
        
        actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(actionsheet, animated: true, completion: nil)
    }
    
    
    private func reloadToDoList(isCalledWithSearch: Bool = false, searchedText: String? = nil)
    {
        self.toDos = nil
        self.toDos = realm.objects(ToDo.self)
        
        if let searchedText = searchedText, isCalledWithSearch
        {
            self.toDosToDisplay = nil
            self.selectedSortingState = .desDate
            
            let predicate = NSPredicate(format: "todoDescription CONTAINS[c] %@", searchedText.lowercased())
            self.toDosToDisplay = self.toDos?.filter(predicate)
        }
        else
        {
            if (selectedSortingState == .pendingTasks)
            {
                let predicate = NSPredicate(format: "isCompleted = false")
                self.toDosToDisplay = self.toDos?
                    .filter(predicate)
                    .sorted(byKeyPath: "updatedAt", ascending: false)
            }
            else if (selectedSortingState == .completedTasks)
            {
                let predicate = NSPredicate(format: "isCompleted = true")
                self.toDosToDisplay = self.toDos?
                    .filter(predicate)
                    .sorted(byKeyPath: "updatedAt", ascending: false)
            }
            else
            {
                self.toDosToDisplay = self.toDos?.sorted(byKeyPath: "updatedAt", ascending: (selectedSortingState == .ascDate) ? true : false)
            }
        }

        self.setClearallVisibility()
        self.setSortingVisibility()
        self.setSearchBarVisibility(isCalledFromActiveSearch: isCalledWithSearch)
        DispatchQueue.main.async { self.tblToDosOutlet.reloadData() }
    }
    
    
    private func setSortingVisibility()
    {
        UIView.animate(withDuration: 0.4) {
            self.btnSortOutlet.isHidden = ((self.toDos?.count ?? 0) > 1) ? false : true
        }
    }
    
    
    private func setClearallVisibility()
    {
        UIView.animate(withDuration: 0.4) {
            self.btnClearAllOutlet.isHidden = RealmService.shared.isRealmDBEmpty() ? true : false
        }
    }
}
