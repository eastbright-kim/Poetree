//
//  PoemService.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/11.
//

import Foundation
import RxSwift

class PoemService {
    
    
//    var poemArr = poems
    
//    private lazy var store = BehaviorSubject<[Poem]>(value: poemArr)
    
    private lazy var photoStore = BehaviorSubject<[URL]>(value: whites)
    
    
    let poemRepository: PoemRepository
    
    init(poemRepository: PoemRepository) {
        self.poemRepository = poemRepository
    }
    
    
    func getWeekPhotoURLs(completion: @escaping ([URL]) -> Void) {
        poemRepository.getWeekPhoto  { [unowned self] url in
            whites = url
            self.photoStore.onNext(url)
            completion(url)
        }
    }
    
    func photos() -> Observable<[URL]> {
        return photoStore
    }
    
    func getCurrentDate() -> String {

        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM-d"
        
        let currentDate = dateFormatter.string(from: date)
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
}
