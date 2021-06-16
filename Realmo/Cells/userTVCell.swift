//
//  userTVCell.swift
//  Realmo
//
//  Created by Chintan Maisuriya on 22/09/20.
//  Copyright © 2020 Chintan Maisuriya. All rights reserved.
//

import UIKit

class userTVCell: UITableViewCell
{
    //MARK: -

    @IBOutlet weak var lblGenderIndicatorOutlet     : UILabel!
    @IBOutlet weak var lblNameOutlet                : UILabel!
    @IBOutlet weak var lblEmailOutlet               : UILabel!
    @IBOutlet weak var lblOtherInfoOutlet           : UILabel!

    //MARK: -

    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    //MARK: -

    func configure(userInfo: User)
    {
        lblGenderIndicatorOutlet.text   = (userInfo.gender.isEqualToString(find: "Other") ? "⚧ " : (userInfo.gender.isEqualToString(find: "Female") ? "♀ " : "♂ "))
        lblNameOutlet.text              = userInfo.name.capitalized
        lblEmailOutlet.text             = "📩 " + userInfo.email
        lblOtherInfoOutlet.text         = "🎂  " + userInfo.getDateInString(isDOB: true) + (((daysUntil(birthday: (userInfo.birthDate!)) == 365) || (daysUntil(birthday: (userInfo.birthDate!)) == 366)) ? "  🎊🥳" : "")
    }
    
    func daysUntil(birthday: Date) -> Int
    {
        let cal = Calendar.current
        let today       = cal.startOfDay(for: Date())
        let date        = cal.startOfDay(for: birthday)
        let components  = cal.dateComponents([.day, .month], from: date)
        let nextDate    = cal.nextDate(after: today, matching: components, matchingPolicy: .nextTimePreservingSmallerComponents)
        return cal.dateComponents([.day], from: today, to: nextDate ?? today).day ?? 0
    }
}
