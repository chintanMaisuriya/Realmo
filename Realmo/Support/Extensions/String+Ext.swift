//
//  SceneDelegate.swift
//  Realmo
//
//  Created by Chintan Maisuriya on 21/09/20.
//  Copyright © 2020 Chintan Maisuriya. All rights reserved.
//

import UIKit


extension String
{
    var length: Int
    {
        return (self as NSString).length
    }
    
    func isEqualToString(find: String) -> Bool
    {
        return String(format: self) == find
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat
    {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox    = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont, minimumTextWrapWidth:CGFloat) -> CGFloat
    {
        var textWidth       : CGFloat = minimumTextWrapWidth
        let incrementWidth  : CGFloat = minimumTextWrapWidth * 0.1
        var textHeight      : CGFloat = self.height(withConstrainedWidth: textWidth, font: font)
        
        //Increase width by 10% of minimumTextWrapWidth until minimum width found that makes the text fit within the specified height
        while textHeight > height
        {
            textWidth += incrementWidth
            textHeight = self.height(withConstrainedWidth: textWidth, font: font)
        }
        
        return ceil(textWidth)
    }
    
    
    func toDateTimeWithZone() -> NSDate
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" //2017-12-23T11:55:57.000Z
        
        let dateFromString : NSDate = dateFormatter.date(from: self)! as NSDate
        
        return dateFromString
    }
    
    func toDateTimeAsNSDate(format : String) -> NSDate
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format //"HH:mm:ss a"
        
        let dateFromString : NSDate = dateFormatter.date(from: self)! as NSDate
        return dateFromString
    }
    
    func toDateTime(format : String) -> Date
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format //"HH:mm:ss a"
        dateFormatter.timeZone = .current
        dateFormatter.locale = .current
        
        let dateFromString = dateFormatter.date(from: self)!
        return dateFromString
    }
    
    func to24DateTime() -> NSDate
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let dateFromString: NSDate   = dateFormatter.date(from: self)! as NSDate
        return dateFromString
    }
    
    func toYearDate() -> NSDate
    {
        let formatter = DateFormatter()
        formatter.dateFormat   = "yyyy-MM-dd"
        let dateFromString: NSDate = formatter.date(from: self)! as NSDate
        
        return dateFromString
    }
    
    func getDateInLOCALFormat(sTimeZone: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        var gmt = NSTimeZone(abbreviation: "\(sTimeZone)")
        
        dateFormatter.timeZone = gmt! as TimeZone
        let date: Date? = dateFormatter.date(from: self)
        
        gmt = NSTimeZone.system as NSTimeZone
        dateFormatter.timeZone = gmt! as TimeZone
        var timeStamp: String = dateFormatter.string(from: date!)
        
        if (timeStamp.count) <= 0
        {
            timeStamp = ""
        }
        
        return timeStamp
    }
    
    
    func convertDateString(fromDateFormat: String? = "yyyy-MM-dd'T'HH:mm:ss.SSSZ", toDateFormat: String? = "yyyy-MM-dd") -> String?
    {
        return convert(dateString: self, fromDateFormat: fromDateFormat!, toDateFormat: toDateFormat!)
    }
    
    
    func convert(dateString: String, fromDateFormat: String, toDateFormat: String) -> String?
    {
        let fromDateFormatter = DateFormatter()
        fromDateFormatter.dateFormat = fromDateFormat
        
        if let fromDateObject = fromDateFormatter.date(from: dateString)
        {
            let toDateFormatter = DateFormatter()
            toDateFormatter.dateFormat = toDateFormat
            toDateFormatter.amSymbol = "am"
            toDateFormatter.pmSymbol = "pm"
            
            let newDateString = toDateFormatter.string(from: fromDateObject)
            return newDateString
        }
        
        return nil
    }
    
    
    func smartContains(_ other: String) -> Bool
    {
        let array : [String] = other.lowercased().components(separatedBy: " ").filter { !$0.isEmpty }
        
        if(array.count != 0)
        {
            return array.reduce(true) { !$0 ? false : (self.lowercased().range(of: $1) != nil ) }
        }
        else
        {
            return false
        }
    }
    
    func capitalizingFirstLetter() -> String
    {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter()
    {
        self = self.capitalizingFirstLetter()
    }
    
    func applyPatternOnNumbers(pattern: String, replacmentCharacter: Character) -> String
    {
        var pureNumber = self.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        
        for index in 0 ..< pattern.count
        {
            guard index < pureNumber.count else { return pureNumber }
            let stringIndex = String.Index(utf16Offset: index, in: self) //String.Index(encodedOffset: index)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacmentCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        
        return pureNumber
    }
    
    func htmlAttributedString(attributes: [NSAttributedString.Key : Any]? = .none, boldString: String? = "", boldStringAttributes: [NSAttributedString.Key : Any]? = .none) -> NSAttributedString?
    {
        guard let data = self.data(using: String.Encoding.utf16, allowLossyConversion: false) else { return nil }
        guard let html = try? NSMutableAttributedString(
                data: data,
                options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
                documentAttributes: nil) else { return nil }
        
        html.setAttributes(attributes, range: NSRange(0..<html.length))
        
        if !((boldString?.isEmpty)!)
        {
            html.setAttributes(boldStringAttributes, range: NSRange(0..<(boldString?.length)!))
        }
        
        return html
    }
    
    func convertStringToDictionary() -> [String: Any]?
    {
        if let data = self.data(using: .utf8)
        {
            do
            {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            }
            catch
            {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func convertJSONStringToDictionary() -> NSDictionary
    {
        if let data = self.data(using: .utf8)
        {
            do
            {
                return try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
            }
            catch
            {
            }
        }
        
        return NSDictionary()
    }
    
    func replace(string:String, replacement:String) -> String
    {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func removeWhitespace() -> String
    {
        return self.replace(string: " ", replacement: "")
    }
    
    func getDecimalConvertedString() -> String
    {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        
        let amunt = formatter.string(from: NSNumber(value: (self as NSString).doubleValue))
        
        return (amunt ?? "0.00")
    }
    
    func attributedStringWithColor(_ strings: [String], color: UIColor, characterSpacing: UInt? = nil) -> NSAttributedString
    {
        let attributedString = NSMutableAttributedString(string: self)
        for string in strings {
            let range = (self as NSString).range(of: string)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        }
        
        guard let characterSpacing = characterSpacing else {return attributedString}
        
        attributedString.addAttribute(NSAttributedString.Key.kern, value: characterSpacing, range: NSRange(location: 0, length: attributedString.length))
        
        return attributedString
    }
    
    
    /// Apply strike font on text
    func strikeThrough(_ isStrikeThrough:Bool) -> NSAttributedString
    {
        let attributeString = NSMutableAttributedString(string: self)
        
        if isStrikeThrough
        {
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSRange(location: 0, length: attributeString.length))
        }
        
        return attributeString
    }
}





extension String {

    fileprivate static let ANYONE_CHAR_UPPER = "X"
    fileprivate static let ONLY_CHAR_UPPER = "C"
    fileprivate static let ONLY_NUMBER_UPPER = "N"
    fileprivate static let ANYONE_CHAR = "x"
    fileprivate static let ONLY_CHAR = "c"
    fileprivate static let ONLY_NUMBER = "n"

    func format(_ format: String, oldString: String) -> String {
        let stringUnformated = self.unformat(format, oldString: oldString)
        var newString = String()
        var counter = 0
        if stringUnformated.count == counter {
            return newString
        }
        for i in 0..<format.count {
            var stringToAdd = ""
            let unicharFormatString = format[i]
            let charFormatString = unicharFormatString
            let charFormatStringUpper = unicharFormatString.uppercased()
            let unicharString = stringUnformated[counter]
            let charString = unicharString
            let charStringUpper = unicharString.uppercased()
            if charFormatString == String.ANYONE_CHAR {
                stringToAdd = charString
                counter += 1
            } else if charFormatString == String.ANYONE_CHAR_UPPER {
                stringToAdd = charStringUpper
                counter += 1
            } else if charFormatString == String.ONLY_CHAR_UPPER {
                counter += 1
                if charStringUpper.isChar() {
                    stringToAdd = charStringUpper
                }
            } else if charFormatString == String.ONLY_CHAR {
                counter += 1
                if charString.isChar() {
                    stringToAdd = charString
                }
            } else if charFormatStringUpper == String.ONLY_NUMBER_UPPER {
                counter += 1
                if charString.isNumber() {
                    stringToAdd = charString
                }
            } else {
                stringToAdd = charFormatString
            }

            newString += stringToAdd
            if counter == stringUnformated.count {
                if i == format.count - 2 {
                    let lastUnicharFormatString = format[i + 1]
                    let lastCharFormatStringUpper = lastUnicharFormatString.uppercased()
                    let lasrCharControl = (!(lastCharFormatStringUpper == String.ONLY_CHAR_UPPER) &&
                                            !(lastCharFormatStringUpper == String.ONLY_NUMBER_UPPER) &&
                                            !(lastCharFormatStringUpper == String.ANYONE_CHAR_UPPER))
                    if lasrCharControl {
                        newString += lastUnicharFormatString
                    }
                }
                break
            }
        }
        return newString
    }

    func unformat(_ format: String, oldString: String) -> String {
        var string: String = self
        var undefineChars = [String]()
        for i in 0..<format.count {
            let unicharFormatString = format[i]
            let charFormatString = unicharFormatString
            let charFormatStringUpper = unicharFormatString.uppercased()
            if !(charFormatStringUpper == String.ANYONE_CHAR_UPPER) &&
                !(charFormatStringUpper == String.ONLY_CHAR_UPPER) &&
                !(charFormatStringUpper == String.ONLY_NUMBER_UPPER) {
                var control = false
                for i in 0..<undefineChars.count {
                    if undefineChars[i] == charFormatString {
                        control = true
                    }
                }
                if !control {
                    undefineChars.append(charFormatString)
                }
            }
        }
        if oldString.count - 1 == string.count {
            var changeCharIndex = 0
            for i in 0..<string.count {
                let unicharString = string[i]
                let charString = unicharString
                let unicharString2 = oldString[i]
                let charString2 = unicharString2
                if charString != charString2 {
                    changeCharIndex = i
                    break
                }
            }
            let changedUnicharString = oldString[changeCharIndex]
            let changedCharString = changedUnicharString
            var control = false
            for i in 0..<undefineChars.count {
                if changedCharString == undefineChars[i] {
                    control = true
                    break
                }
            }
            if control {
                var i = changeCharIndex - 1
                while i >= 0 {
                    let findUnicharString = oldString[i]
                    let findCharString = findUnicharString
                    var control2 = false
                    for j in 0..<undefineChars.count {
                        if findCharString == undefineChars[j] {
                            control2 = true
                            break
                        }
                    }
                    if !control2 {
                        string = (oldString as NSString).replacingCharacters(in: NSRange(location: i, length: 1), with: "")
                        break
                    }
                    i -= 1
                }
            }
        }
        for i in 0..<undefineChars.count {
            string = string.replacingOccurrences(of: undefineChars[i], with: "")
        }
        return string
    }

    fileprivate func isChar() -> Bool {
        return regexControlString(pattern: "[a-zA-ZğüşöçıİĞÜŞÖÇ]")
    }

    fileprivate func isNumber() -> Bool {
        return regexControlString(pattern: "^[0-9]*$")
    }

    fileprivate func regexControlString(pattern: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let numberOfMatches = regex.numberOfMatches(in: self, options: [], range: NSRange(location: 0, length: self.count))
            return numberOfMatches == self.count
        } catch {
            return false
        }
    }
}

extension String {

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(count, r.lowerBound)),
                                            upper: min(count, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        let rangeLast: Range<Index> = start..<end
        return String(self[rangeLast])
    }
}
