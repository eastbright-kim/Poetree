//
//  PhotoRepository.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/16.
//

import Foundation
import Firebase


class PhotoRepository {
    
    static let shared = PhotoRepository()
    
    public func fetchPhotos(completion: @escaping (([PhotoEntity]) -> Void)) {
        
        photoRef.observeSingleEvent(of: .value) { snapshot in
            let value = snapshot.value as? [String:Any] ?? [:]
            
            var photoEntity = [PhotoEntity]()
            
            for value in value.values {
                let dic = value as! [String : Any]
                print(dic)
                let photo = PhotoEntity(photoDic: dic)
                photoEntity.append(photo)
            }
            completion(photoEntity)
        }
    }
}
