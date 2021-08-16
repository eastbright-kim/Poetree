//
//  PoemService.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/11.
//

import Foundation
import RxSwift
import Firebase
import FirebaseAuth
import Kingfisher
class PoemService {
    
    private var weekPhotos = [WeekPhoto]()
    
    
    private lazy var photoStore = BehaviorSubject<[WeekPhoto]>(value: whites)
    private lazy var thisWeekPhotoStore = BehaviorSubject<[WeekPhoto]>(value: whites)
    
    let poemRepository: PoemRepository
    
    init(poemRepository: PoemRepository) {
        self.poemRepository = poemRepository
    }
   
    func getWeekPhotos(completion: @escaping ([WeekPhoto]) -> Void) {
        poemRepository.fetchPhotos {[unowned self] photoEntities in
          let weekPhotos = photoEntities.map { entity -> WeekPhoto in
            let url = URL(string: entity.imageURL)!
            let photoId = entity.photoId
            let date = converStringToDate(dateFormat: "YYYY MMM d", dateString: entity.date)
                return WeekPhoto(date: date, id: photoId, url: url)
            }
            completion(weekPhotos)
            self.weekPhotos = weekPhotos
            self.getThisWeekPhoto(photos: weekPhotos)
            self.photoStore.onNext(weekPhotos)
        }
    }
    @discardableResult
    func photos() -> Observable<[WeekPhoto]> {
        return photoStore
    }
    
    @discardableResult
    func thisWeekPhotos() -> Observable<[WeekPhoto]> {
        return thisWeekPhotoStore
    }
    
    @discardableResult
    func getThisWeekPhoto(photos: [WeekPhoto]) -> Observable<[WeekPhoto]> {
        
        let sortedArr = photos.sorted { p1, p2 in
            Double(p1.date.timeIntervalSince1970) > Double(p2.date.timeIntervalSince1970)
        }.suffix(3)
        print(Array(sortedArr))
        self.thisWeekPhotoStore.onNext(Array(sortedArr))
        return Observable.just(Array(sortedArr))
    }
    
    func createPoem(poem: Poem, completion: @escaping ((String) -> Void)) {
        
        poemRepository.createPoem(poemModel: poem) { result in
            switch result {
            case .success(let s):
                completion(s.rawValue)
            case .failure:
                completion("write poem error")
            }
        }
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
