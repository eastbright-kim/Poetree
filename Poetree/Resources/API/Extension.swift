//
//  Extension.swift
//  Poetree
//
//  Created by 김동환 on 2021/09/17.
//

import UIKit


extension UIButton {
    
    func animateView(){
        UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveLinear) {
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { _ in
            UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveLinear, animations: {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
        }
    }
}

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday, .weekOfYear, .yearForWeekOfYear], from: self).weekday
    }
}

//
//extension Date {
//    static var yesterday: Date { return Date().dayBefore }
//    static var tomorrow:  Date { return Date().dayAfter }
//    
//    var twoWeekBefore: Date {
//        return Calendar.current.date(byAdding: .day, value: -14, to: noon)!
//    }
//    
//    var aWeekBefore: Date {
//        return Calendar.current.date(byAdding: .day, value: -7, to: noon)!
//    }
//    
//    var dayBefore: Date {
//        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
//    }
//    var dayAfter: Date {
//        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
//    }
//    var noon: Date {
//        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
//    }
//    var month: Int {
//        return Calendar.current.component(.month,  from: self)
//    }
//    var isLastDayOfMonth: Bool {
//        return dayAfter.month != month
//    }
//}
