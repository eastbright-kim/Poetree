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
            "userUID": poemModel.userUID,
            "isTemp": poemModel.isTemp
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
    
    func likeAdd(poem: Poem, user: User) {
        
        poemRef.child(poem.userUID).child(poem.id).runTransactionBlock { currentData in
            
            if var updatedPoem = currentData.value as? [String:Any] {
                var likers = updatedPoem["likers"] as? [String:Bool] ?? [:]
                likers[user.uid] = true
                updatedPoem["likers"] = likers
                currentData.value = updatedPoem
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }
    }
    
    func likeCancel(poem: Poem, user: User){
        
        poemRef.child(poem.userUID).child(poem.id).runTransactionBlock { currentData in
            
            if var updatedPoem = currentData.value as? [String:Any] {
                var likers = updatedPoem["likers"] as? [String:Bool] ?? [:]
                likers.removeValue(forKey: user.uid)
                updatedPoem["likers"] = likers
                currentData.value = updatedPoem
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }
    }
    
    func editPoemFromTemp(poemModel: Poem, completion: @escaping ((Result<Complete, Error>) -> Void)) {
        
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
            "userUID": poemModel.userUID,
            "isTemp": poemModel.isTemp
        ]
        poemRef.child(poemModel.userUID).child(poemModel.id).setValue(poemDic)
        completion(.success(.writedPoem))
    }
    
    func reportPoem(poem: Poem, currentUser: User?, completion: @escaping (() -> Void)) {
        
        let reportedPoemDict: [String:String] = [
            "poemId" : poem.id,
            "reporter" : currentUser?.uid ?? "unknown"
        ]
        reportedPoemRef.child(poem.userUID).child(currentUser?.uid ?? "unknown").setValue(reportedPoemDict)
        completion()
    }
}
