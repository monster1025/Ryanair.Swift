//
//  NSDate.swift
//  ryan
//
//  Created by monster on 05.12.15.
//  Copyright © 2015 monster. All rights reserved.
//

import Foundation

extension NSDate {
    func dateFromString(date: String, format: String = "yyyy-MM-dd") -> NSDate {
        let formatter = NSDateFormatter()
        let locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        formatter.locale = locale
        formatter.dateFormat = format
        
        return formatter.dateFromString(date)!
    }
    
    func toString(format: String = "yyyy-MM-dd") -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format //format style. Browse online to get a format that fits your needs.
        let dateString = dateFormatter.stringFromDate(self)
        return dateString
    }
    
    func add(days: Int, unit: NSCalendarUnit = .Day) -> NSDate {
        let userCalendar = NSCalendar.currentCalendar()
        return userCalendar.dateByAddingUnit(
            unit,
            value: days,
            toDate: self,
            options: [])!
    }
}