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
