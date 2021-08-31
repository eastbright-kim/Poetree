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

func convertStringToDate(dateFormat: String, dateString: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat
    let date = dateFormatter.date(from: dateString)!
    return date
}

func getWeek(day: Int) -> String {
    switch day {
    case 1...7:
        return "1st"
    case 8...14:
        return "2nd"
    case 15...21:
        return "3rd"
    case 22...27:
        return "4th"
    default:
        return "5th"
    }
}

func getCycleString(time: Int) -> String {
    switch time {
    case 6..<12:
       return "아침"
    case 12..<18:
       return "낮"
    case 18..<21:
       return "저녁"
    default:
       return "밤"
    }
}

func getMonday(myDate: Date) -> Date {
    let cal = Calendar.current
    var comps = cal.dateComponents([.weekOfYear, .yearForWeekOfYear], from: myDate)
    comps.weekday = 2 // Monday
    let mondayInWeek = cal.date(from: comps)!
    return mondayInWeek
}
