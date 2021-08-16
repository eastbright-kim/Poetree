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
    
    private var weekPhotos = [WeekPhoto]()
    private lazy var photoStore = BehaviorSubject<[WeekPhoto]>(value: whites)
    private lazy var thisWeekPhotoStore = BehaviorSubject<[WeekPhoto]>(value: whites)
    
    let photoRepository: PhotoRepository
    
    init(photoRepository: PhotoRepository) {
        self.photoRepository = photoRepository
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
            self.getThisWeekPhoto(photos: weekPhotos)
            self.photoStore.onNext(weekPhotos)
        }
    }
}
