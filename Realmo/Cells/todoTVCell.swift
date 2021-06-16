//
//  todoTVCell.swift
//  Realmo
//
//  Created by Chintan Maisuriya on 21/09/20.
//  Copyright © 2020 Chintan Maisuriya. All rights reserved.
//

import UIKit

class todoTVCell: UITableViewCell
{
    //MARK: -
    
    private var toDoTask: ToDo?
    
    //MARK: -

    @IBOutlet weak var viewBGOutlet: UIViewX!
    @IBOutlet weak var viewDayIndicatorOutlet   : UIView!
    @IBOutlet weak var lblDescriptionOutlet     : UILabel!
    @IBOutlet weak var lblDateOutlet            : UILabel!
    
    //MARK: -

    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.viewDayIndicatorOutlet.roundCorners([.topLeft, .bottomLeft], radius: 12)
    }

    //MARK: -
    
    private func getBorderColor() -> UIColor
    {
        return (toDoTask?.isCompleted ?? false) ? .white : .systemBackground
    }
    
    private func getBackgroundColor() -> UIColor
    {
        return (toDoTask?.isCompleted ?? false) ? .systemGray4 : .systemBackground
    }
    
    private func getIndicatorColor() -> UIColor
    {
        guard let todoInfo = toDoTask else { return .darkGray }
        guard !(todoInfo.isCompleted) else { return .clear }
        
        if let taskDate = todoInfo.createdAt
        {
            if taskDate.isFutureDate
            {
                return .systemTeal
            }
            else if taskDate.isDateInToday
            {
                return .systemGreen
            }
            else if taskDate.isDateInYesterday
            {
                return .systemOrange
            }
            else if taskDate.isPastDate
            {
                return .systemYellow
            }
        }
        
        return .systemPink
    }
}


//MARK: -

extension todoTVCell
{
    func configure(todoInfo: ToDo)
    {
        toDoTask = todoInfo
        
        viewBGOutlet.borderColor                = getBorderColor()
        viewBGOutlet.backgroundColor            = getBackgroundColor()
        viewDayIndicatorOutlet.backgroundColor  = getIndicatorColor()

        lblDescriptionOutlet.attributedText     = todoInfo.todoDescription.strikeThrough(todoInfo.isCompleted)
        lblDateOutlet.text                      = todoInfo.getDateInString()
    }
}
