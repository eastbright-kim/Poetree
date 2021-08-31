//
//  PhotoService.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/16.
//

import Foundation
import RxSwift
import Firebase

class PhotoService {
    
    var weekPhotos = [WeekPhoto]()
    lazy var photoStore = BehaviorSubject<[WeekPhoto]>(value: whites)
    
    
    let photoRepository: PhotoRepository
    
    init(photoRepository: PhotoRepository) {
        self.photoRepository = photoRepository
    }
    
    @discardableResult
    func photos() -> Observable<[WeekPhoto]> {
        return photoStore
    }
    
    
    func getThisWeekPhoto(_ photos: [WeekPhoto]) -> [WeekPhoto] {
        
        let sortedArr = photos.sorted { p1, p2 in
            Double(p1.date.timeIntervalSince1970) > Double(p2.date.timeIntervalSince1970)
        }.prefix(3)
       
        return Array(sortedArr)
    }
    
    func getWeekPhotos(completion: @escaping ([WeekPhoto]) -> Void) {
        photoRepository.fetchPhotos {[unowned self] photoEntities in
            let weekPhotos = photoEntities.map { entity -> WeekPhoto in
                let url = URL(string: entity.imageURL)!
                let photoId = entity.photoId
                let date = convertStringToDate(dateFormat: "YYYY MMM d", dateString: entity.date)
                return WeekPhoto(date: date, id: photoId, url: url)
            }
            completion(weekPhotos)
            self.weekPhotos = weekPhotos
            self.photoStore.onNext(weekPhotos)
        }
    }
    
    func fetchPhotoId(photos: [WeekPhoto], _ index: Int) -> Int {
        
        let thisWeekPhotos = getThisWeekPhoto(photos)
        
        let id = thisWeekPhotos[index].id
        return id
    }
    
}
