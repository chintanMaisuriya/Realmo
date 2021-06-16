//
//  SceneDelegate.swift
//  Realmo
//
//  Created by Chintan Maisuriya on 21/09/20.
//  Copyright © 2020 Chintan Maisuriya. All rights reserved.
//

import UIKit


extension UITableView
{
    func scroll(to: scrollsTo, animated: Bool)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            let numberOfSections = self.numberOfSections
            
            guard numberOfSections > 0 else { return }
            
            let numberOfRows = self.numberOfRows(inSection: numberOfSections-1)
            switch to{
            case .top:
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.scrollToRow(at: indexPath, at: .top, animated: animated)
                }
                break
            case .bottom:
                if numberOfRows > 0 {
                    let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                    self.scrollToRow(at: indexPath, at: .bottom, animated: animated)
                }
                break
            }
        }
    }
    
    
    enum scrollsTo
    {
        case top,bottom
    }
    
    
    func positionedAtBottom() -> Bool
    {
        let height = self.contentSize.height - self.frame.size.height
        
        if self.contentOffset.y < 10 {
            //reach top
            return false
        }
        else if self.contentOffset.y < height/2.0
        {
            //not top and not bottom
            return false
        }
        else
        {
            return true
        }
    }
    
    
    func showNoDataLabel(_ strAltMsg: String, isScrollable: Bool)
    {
        let noDataView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        
        let msglbl               = UILabel(frame: CGRect(x: 12, y: 25, width: self.bounds.size.width-24, height: self.bounds.size.height-50))
        msglbl.text          = strAltMsg
        msglbl.textAlignment = .center
        msglbl.font          = UIFont(name: "Helvetica", size: 20.0)
        msglbl.numberOfLines = 0
        msglbl.textColor     = UIColor(white: 0.75, alpha: 1.0)
        
        msglbl.translatesAutoresizingMaskIntoConstraints = true
        
        noDataView.addSubview(msglbl)
        noDataView.translatesAutoresizingMaskIntoConstraints = true
        
        self.isScrollEnabled = isScrollable
        self.backgroundView  = noDataView
    }
    
    
    func removeNoDataLabel()
    {
        self.isScrollEnabled = true
        self.backgroundView  = nil
    }
    
}
