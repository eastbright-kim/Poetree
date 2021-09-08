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

    
    func createPoem(poemModel: Poem, completion: @escaping ((Result<Complete, Error>) -> Void)) {
        
        let currentUser = Auth.auth().currentUser
        
        let poemDic: [String:Any] = [
            "id" : poemModel.id as Any,
            "userEmail": currentUser!.email as Any,
            "userPenname": currentUser!.displayName as Any,
            "title": poemModel.title,
            "content": poemModel.content,
            "photoId": poemModel.photoId,
            "uploadAt": convertDateToString(format: "yyyy MMM d", date: poemModel.uploadAt),
            "isPrivate": poemModel.isPrivate,
            "likers": [:],
            "photoURL": poemModel.photoURL.absoluteString,
            "userUID": poemModel.userUID
        ]
        poemRef.child(poemModel.userUID).child(poemModel.id).setValue(poemDic)
        completion(.success(.writedPoem))
    }
    
    func deletePoem(poemModel: Poem) {
        
        poemRef.child(poemModel.userUID).child(poemModel.id).removeValue()
        
    }
    
    public func fetchPoems(completion: @escaping (([PoemEntity], Result<[String:[Poem]], Error>)) -> Void) {
        
        poemRef.observeSingleEvent(of: .value) { snapshot in
            
            let allUsers = snapshot.value as? [String:Any] ?? [:]
       
            var poemEntities = [PoemEntity]()
            var uid_poem = [String:[Poem]]()
            
            for user in allUsers {
                let userDict = user.value as! [String:Any]
                let uid = user.key
                uid_poem.updateValue([], forKey: uid)
                for poemDict in userDict.values {
                    let poemDict = poemDict as! [String:Any]
                    let poemEntity = PoemEntity(poemDic: poemDict)
                    poemEntities.append(poemEntity)
                }
            }
            completion((poemEntities, .success(uid_poem)))
        }
    }
}
