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
        let sortedArr = photos.prefix(3)
        return Array(sortedArr)
    }
    
    func fetchPhotos(completion: @escaping ((Complete) -> Void)){
        
        self.photoRepository.fetchPhotos { photoEntities in
            let weekPhotos = photoEntities.map { entity -> WeekPhoto in
                let url = URL(string: entity.imageURL)!
                let photoId = entity.photoId
                let date = convertStringToDate(dateFormat: "yyyy MMM d", dateString: entity.date)
                return WeekPhoto(date: date, id: photoId, url: url)
            }.sorted { p1, p2 in
                p1.date.timeIntervalSinceReferenceDate > p2.date.timeIntervalSinceReferenceDate
            }.filter { weekPhoto in
                
                let thisMonday = getThisMonday(myDate: Date())
                return weekPhoto.date.timeIntervalSinceReferenceDate <= thisMonday.timeIntervalSinceReferenceDate
            }
            self.weekPhotos = weekPhotos
            self.photoStore.onNext(self.weekPhotos)
            completion(.fetchedPhoto)
        }
    }
    
    func fetchLastWeekPhotos(weekPhotos: [WeekPhoto]) -> [WeekPhoto] {
        let lastWeekPhotos = weekPhotos.dropFirst(3)
        return Array(lastWeekPhotos)
    }
    
    
    func fetchPhotoId(photos: [WeekPhoto], _ index: Int) -> Int {
        
        let thisWeekPhotos = getThisWeekPhoto(photos)
        let id = thisWeekPhotos[index].id
        return id
    }
    
    func fetchPhotoById(_ photos: [WeekPhoto], id: Int) -> WeekPhoto{
        
        let photo = photos.filter { weekPhoto in
            weekPhoto.id == id
        }
        return photo.first!
    }
    
    func getInitialPhoto(_ photos: [WeekPhoto]) -> WeekPhoto? {
        return photos.first
    }
    
    func photoReveredOrder(_ photos: [WeekPhoto]) -> [WeekPhoto] {
        return photos.reversed()
    }
    
}

