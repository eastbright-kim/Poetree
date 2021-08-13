//
//  PoemRepository.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/11.
//

import Foundation
import Kingfisher
import Firebase

class PoemRepository {
    
    let ref = Database.database().reference()
    
    var weekPhotos = [WeekPhoto]()
    
    func fetchPhotos(completion: @escaping (([PhotoEntity]) -> Void)) {
        
        ref.child("photos").observeSingleEvent(of: .value) { snapshot in
            let valud = snapshot.value as? [String:Any] ?? [:]
            
            var photoEntity = [PhotoEntity]()
            
            for value in valud.values {
                let dic = value as! [String : Any]
                print(dic)
                let photo = PhotoEntity(photoDic: dic)
                photoEntity.append(photo)
            }
            completion(photoEntity)
        }
    }
}
