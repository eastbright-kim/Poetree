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
    
    func createPoem(poemModel: Poem,completion: @escaping ((Result<Complete, Errors>) -> Void)) {
        
        let currentUser = Auth.auth().currentUser!
        
        let poemDic: [String:Any] = [
            "id" : currentUser.uid as Any,
            "userEmail": currentUser.email as Any,
            "userNickname": currentUser.displayName as Any,
            "title": poemModel.title,
            "content": poemModel.content,
            "photoId": poemModel.photoId,
            "uploadAt": convertDateToString(format: "MMM d", date: poemModel.uploadAt),
            "isPublic": poemModel.isPublic,
            "likers": [],
            "photoURL": poemModel.photoURL.absoluteString
        ]
        
        
        
        ref.child("poem").child(currentUser.uid).setValue(poemDic)
        completion(.success(.writedPoem))
    }
}
