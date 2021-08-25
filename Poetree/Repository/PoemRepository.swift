//
//  PoemRepository.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/11.
//

import Foundation
import Firebase


class PoemRepository {
    
    static let shared = PoemRepository()
    
    
    func createPoem(poemModel: Poem, completion: @escaping ((Result<Complete, Errors>) -> Void)) {
    
        let poemDic: [String:Any] = [
            "id" : poemModel.id as Any,
            "userEmail": currentUser.email as Any,
            "userNickname": currentUser.displayName as Any,
            "title": poemModel.title,
            "content": poemModel.content,
            "photoId": poemModel.photoId,
            "uploadAt": convertDateToString(format: "MMM d", date: poemModel.uploadAt),
            "isPrivate": poemModel.isPrivate,
            "likers": [:],
            "photoURL": poemModel.photoURL.absoluteString
        ]
        poemRef.child(poemModel.id).setValue(poemDic)
        completion(.success(.writedPoem))
    }
    
    func deletePoem(poemModel: Poem) {
        
        poemRef.child(poemModel.id).removeValue()
        
    }
    
    public func fetchPoems(completion: @escaping (([PoemEntity], Result<Complete, Error>)) -> Void) {
        
        poemRef.observeSingleEvent(of: .value) { snapshot in
            
            let snapshotValue = snapshot.value as? [String:Any] ?? [:]
            var poemEntities = [PoemEntity]()
            for value in snapshotValue.values {
                let poemDic = value as! [String:Any]
                let poemEntity = PoemEntity(poemDic: poemDic)
                poemEntities.append(poemEntity)
            }
            completion((poemEntities, .success(.fetchedPoem)))
        }
    }
}
