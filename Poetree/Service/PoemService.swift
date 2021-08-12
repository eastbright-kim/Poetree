//
//  PoemService.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/11.
//

import Foundation
import RxSwift
import FirebaseAuth

class PoemService {
    
    
    private lazy var photoStore = BehaviorSubject<[WeekPhoto]>(value: whites)
    
    
    let poemRepository: PoemRepository
    
    init(poemRepository: PoemRepository) {
        self.poemRepository = poemRepository
    }
    
    
    func getWeekPhoto(completion: @escaping ([WeekPhoto]) -> Void) {
        
        poemRepository.getWeekPhoto  { [unowned self] weekPhoto in
            
            whites = weekPhoto
            photoStore.onNext(weekPhoto)
            completion(weekPhoto)
        }
    }
    
    func photos() -> Observable<[WeekPhoto]> {
        return photoStore
    }
    
    func getCurrentDate() -> String {

        let currentDate = convertDateToString(format: "MMM-d", date: Date())
        
        
        let current = currentDate.components(separatedBy: "-")
        
        let day = Int(current[1])!
        let week = getWeek(day: day)
        
        
        return "\(current[0]) \(week)"
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
    
    func getCurrentWritingTime() -> String {
        
        let monthDay = convertDateToString(format: "M월 d일", date: Date())
        let time = Int(convertDateToString(format: "H", date: Date()))!
        
        let cycle = getCycleString(time: time)
        
        let user = Auth.auth().currentUser?.displayName ?? "user"
        
        return "\(user)님이 \(monthDay) \(cycle)에 보내는 글"
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
}
