//
//  Function.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/12.
//

import Foundation


func convertDateToString(format: String, date: Date) -> String {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    let dateString = dateFormatter.string(from: date)
    return dateString
    
}

func converStringToDate(dateFormat: String, dateString: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat
    let date = dateFormatter.date(from: dateString)!
    return date
}
