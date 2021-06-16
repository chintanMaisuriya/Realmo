//
//  AddUserVC.swift
//  Realmo
//
//  Created by Chintan Maisuriya on 22/09/20.
//  Copyright © 2020 Chintan Maisuriya. All rights reserved.
//

import UIKit
import RealmSwift

class AddUserVC: UIViewController
{
    
    //MARK: -
    let realm = RealmService.shared.getDefaultInstance()
    var realmNotificationToken: NotificationToken?

    var isComeForEditUser: Bool = false
    var arrGender = ["Male", "Female", "Other"]
    var strSelectedGender = "Male"
    
    var userInfoToEdit              : User? = nil
    private var dobDatePicker       : UIDatePicker? = nil
    private var userGenderPicker    : UIPickerView? = nil
    
    //MARK: -
    
    @IBOutlet weak var txtNameOutlet    : UITextField!
    @IBOutlet weak var txtEmailOutlet   : UITextField!
    @IBOutlet weak var txtDOBOutlet     : UITextField!
    @IBOutlet weak var txtGenderOutlet  : UITextField!
    @IBOutlet weak var btnSaveOutlet    : UIButton!
    
    //MARK: -
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.initialConfiguration()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        realmNotificationToken?.invalidate()
    }
    
    //MARK: -
    
    @IBAction func btnSaveAction(_ sender: UIButton)
    {
        if self.checkValidation()
        {
            if self.isComeForEditUser
            {
                guard let userInfo = self.userInfoToEdit else { return }
                let dix: [String : Any] = ["name": self.txtNameOutlet.text!, "email": self.txtEmailOutlet.text!, "gender": self.txtGenderOutlet.text!, "birthDate": (self.txtDOBOutlet.text!).toDateTime(format: "dd/MM/yyyy"), "updatedAt" : Date()]
                RealmService.shared.updateOnRealm(userInfo, with: dix)
            }
            else
            {
                let predicate = NSPredicate(format: "email = %@", self.txtEmailOutlet.text!)
                let users = realm.objects(User.self).filter(predicate)
                
                if users.isEmpty
                {
                    let user = User(strName: self.txtNameOutlet.text!, strEmail: self.txtEmailOutlet.text!, strGender: self.txtGenderOutlet.text!, birhtDate: self.txtDOBOutlet.text?.toDateTime(format: "dd/MM/yyyy"), createdDate: Date(), updatedDate: Date())
                    RealmService.shared.addToRealm(user)
                }
                else
                {
                    self.showAlert(title: "Caution!", message: "User with same email address is already added!")
                }                
                
            }
        }
        
    }
    
    /*
     // MARK: - Navigation
     */
    
}

//MARK: - UIPickerview

extension AddUserVC: UIPickerViewDataSource, UIPickerViewDelegate
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return self.arrGender.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        var label: UILabel
        if let view = view as? UILabel { label = view }
        else { label = UILabel() }
        
        label.textColor                 = UIColor(named: "Color1")
        label.textAlignment             = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor        = 0.5
        label.font                      = UIFont.systemFont(ofSize: 22)
        label.text                      = self.arrGender[row]
        
        return label
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return self.arrGender[row]
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        self.strSelectedGender      = self.arrGender[row]
        self.txtGenderOutlet.text   = self.strSelectedGender
    }
    
}



//MARK: -

extension AddUserVC
{
    func initialConfiguration()
    {
        self.navigationController?.navigationBar.tintColor = UIColor(named: "Color1")
        self.title = isComeForEditUser ? "Edit User" : "Add User"
        
        self.initialiseTexfield(self.txtNameOutlet)
        self.initialiseTexfield(self.txtEmailOutlet)
        self.initialiseTexfield(self.txtDOBOutlet)
        self.initialiseTexfield(self.txtGenderOutlet)
       
        self.setDatepicker(self.txtDOBOutlet)
        self.setGenderPicker(self.txtGenderOutlet)
        
        self.btnSaveOutlet.layer.cornerRadius   = 6
        self.btnSaveOutlet.clipsToBounds        = true
        self.btnSaveOutlet.setTitle(self.isComeForEditUser ? "EDIT" : "SAVE", for: .normal)
        
        
        if self.isComeForEditUser
        {
            self.setInfoToEdit()
        }
        
        realmNotificationToken = realm.observe { (notification, realm) in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func initialiseTexfield(_ textfield: UITextField)
    {
        textfield.layer.borderColor    = UIColor.systemGray5.cgColor
        textfield.layer.borderWidth    = 1
        textfield.layer.cornerRadius   = 8
        textfield.clipsToBounds        = true
    }
    
    
    //--
    
    private func setDatepicker(_ textField: UITextField)
    {
        let calendar            = Calendar.current
        
        var minDateComponent    = calendar.dateComponents([.day,.month,.year], from: Date())
        minDateComponent.day    = 01
        minDateComponent.month  = 01
        minDateComponent.year   = 1945
        
        let minDate             = calendar.date(from: minDateComponent)
        let currentDate         = Date()
        
        dobDatePicker                           = UIDatePicker.init()
        dobDatePicker?.preferredDatePickerStyle = .wheels
        dobDatePicker?.datePickerMode           = .date
        dobDatePicker?.date                     = currentDate
        dobDatePicker?.minimumDate              = minDate
        dobDatePicker?.maximumDate              = currentDate
        
        dobDatePicker?.setValue(UIColor(named: "Color1"), forKeyPath: "textColor")
        dobDatePicker?.addTarget(self, action: #selector(updateDOBvalue(sender:)), for: .valueChanged)
        
        textField.inputView                 = dobDatePicker
        textField.keyboardToolbar.tintColor = UIColor(named: "Color1")
        
        textField.addPreviousNextDoneOnKeyboardWithTarget(self, previousAction: #selector(previousAction(_:)), nextAction: #selector(nextAction(_:)), doneAction: #selector(selectDayAction(_:)), shouldShowPlaceholder: true)
    }
    
    
    @objc func updateDOBvalue(sender: UIDatePicker) -> Void
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        self.txtDOBOutlet.text = formatter.string(from: sender.date)
    }
    
    
    @objc func selectDayAction(_ barButton: UIBarButtonItem)
    {
        let dateformate = DateFormatter()
        dateformate.dateFormat = "dd/MM/yyyy"
        
        self.txtDOBOutlet.text = dateformate.string(from: (dobDatePicker?.date)!)
        view.endEditing(true)
    }
    
    //--
    
    private func setGenderPicker(_ txtF: UITextField)
    {
        if self.arrGender.count > 0
        {
            userGenderPicker                   = UIPickerView()
            userGenderPicker?.delegate         = self
            userGenderPicker?.tag              = 2001
            userGenderPicker?.autoresizingMask = [.flexibleWidth,.flexibleHeight]
            userGenderPicker?.selectRow(self.arrGender.firstIndex(of: strSelectedGender) ?? 0, inComponent: 0, animated: false)
            
            txtF.inputView = userGenderPicker
            txtF.keyboardToolbar.tintColor = UIColor(named: "Color1")
            
            txtF.addPreviousNextDoneOnKeyboardWithTarget(self, previousAction: #selector(previousAction(_:)), nextAction: #selector(nextAction(_:)), doneAction: #selector(selectGenderAction(_:)), shouldShowPlaceholder: true)
        }
    }
    
    
    @objc func selectGenderAction(_ barButton: UIBarButtonItem)
    {
        self.txtGenderOutlet.text = "\((self.arrGender[self.userGenderPicker?.selectedRow(inComponent: 0) ?? 0]).capitalized)"
        view.endEditing(true)
    }
    
    //--
    
    
    @objc func previousAction(_ button: Any)
    {
        IQKeyboardManager.shared.goPrevious()
    }
    
    
    @objc func nextAction(_ button: Any)
    {
        IQKeyboardManager.shared.goNext()
    }
    
    
    //--
    
    private func setInfoToEdit()
    {
        guard let user = self.userInfoToEdit else { return }
        
        self.txtNameOutlet.text     = user.name.capitalized
        self.txtEmailOutlet.text    = user.email
        self.txtDOBOutlet.text      = user.getDateInString(isDOB: true)
        self.txtGenderOutlet.text   = user.gender.capitalized
        
        self.strSelectedGender      = user.gender
        self.dobDatePicker?.date    = (user.getDateInString(isDOB: true).isEmpty) ? Date() : user.birthDate!
        
    }
    
    private func checkValidation() -> Bool
    {
        self.view.endEditing(true)
        
        self.txtNameOutlet.text     = self.trimString(self.txtNameOutlet.text ?? "")
        self.txtEmailOutlet.text    = self.trimString(self.txtEmailOutlet.text ?? "")
        self.txtDOBOutlet.text      = self.trimString(self.txtDOBOutlet.text ?? "")
        self.txtGenderOutlet.text   = self.trimString(self.txtGenderOutlet.text ?? "")

        
        if (self.txtNameOutlet.text?.isEmpty)!
        {
            self.showAlert(title: "Oops!", message: "Please enter your name")
            return false
        }
        else if (self.txtEmailOutlet.text?.isEmpty)!
        {
            self.showAlert(title: "Oops!", message: "Please enter your email address")
            return false
        }
        else if (!self.validateEmail((self.txtEmailOutlet?.text)!))
        {
            self.showAlert(title: "Oops!", message: "Please enter valid email address")
            return false
        }
        else if (self.txtDOBOutlet.text?.isEmpty)!
        {
            self.showAlert(title: "Oops!", message: "Please select your date of birth")
            return false
        }
        else if (self.txtGenderOutlet.text?.isEmpty)!
        {
            self.showAlert(title: "Oops!", message: "Please enter your gender")
            return false
        }
        
        return true
    }
    
    //--
    
    func showAlert(title:String, message:String)
    {
        let alertView = UIAlertController(title: title, message: message, preferredStyle:.alert)
        let btnOK     = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertView.addAction(btnOK)
        self.present(alertView, animated: true, completion: nil)
    }
    
    func trimString(_ text: String) -> String
    {
        let trimmedString: String = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return trimmedString
    }
    
    func validateEmail(_ emailStr: String) -> Bool
    {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest  = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: emailStr)
    }
}
