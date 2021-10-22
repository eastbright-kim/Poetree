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
            "userEmail": currentUser?.email ?? currentUser?.uid as Any,
            "userPenname": currentUser?.displayName ?? "" as Any,
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
    
    public func fetchPoems(completion: @escaping ([PoemEntity]) -> Void) {
        
        poemRef.observeSingleEvent(of: .value) { snapshot in
            
            let allUsers = snapshot.value as? [String:Any] ?? [:]
            
            var poemEntities = [PoemEntity]()
            
            for user in allUsers {
                let userDict = user.value as! [String:Any]
                for poemDict in userDict.values {
                    let poemDict = poemDict as! [String:Any]
                    let poemEntity = PoemEntity(poemDic: poemDict)
                    poemEntities.append(poemEntity)
                }
            }
            completion(poemEntities)
        }
    }
    
    func addLikesToPoem(poem: Poem, user: User) {
        
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
    
    func cancelLike(poem: Poem, user: User){
        
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
    
    func editTempSavedPoem(poemModel: Poem, completion: @escaping ((Result<Complete, Error>) -> Void)) {
        
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
    
    
    func updatePenname(poems: [Poem], currentAuth: CurrentAuth){
        
        for poem in poems {
            poemRef.child(poem.userUID).child(poem.id).updateChildValues(["userPenname":currentAuth.userPenname])
        }
    }
    
    
    func reportPoem(poem: Poem, currentUser: User?, completion: @escaping (() -> Void)) {
        
        guard let currentUser = currentUser else {
            return
        }
        
        let reportedPoemDict: [String:String] = [
            "poemId" : poem.id,
            "reporter" : currentUser.uid,
            "title" : poem.title,
            "content": poem.content
        ]
        
        reportedPoemRef.child(poem.userUID).child(poem.id).setValue(reportedPoemDict)
        
        poemRef.child(poem.userUID).child(poem.id).runTransactionBlock { currentData in
            if var updatedPoem = currentData.value as? [String:Any] {
                var reportedUser = updatedPoem["reportedUsers"] as? [String:Bool] ?? [:]
                reportedUser[currentUser.uid] = true
                updatedPoem["reportedUsers"] = reportedUser
                currentData.value = updatedPoem
                return TransactionResult.success(withValue: currentData)
            }
            completion()
            return TransactionResult.success(withValue: currentData)
        }
    }
    
    func blockWriter(poem: Poem, currentUser: User?, completion: @escaping (() -> Void)){
        
        guard let currentUser = currentUser else {
            return
        }
        
        let reportedPoemDict: [String:String] = [
            "poemId" : poem.id,
            "reporter" : currentUser.uid,
            "title" : poem.title,
            "content": poem.content
        ]
        
        reportedPoemRef.child(poem.userUID).child(poem.id).setValue(reportedPoemDict)
        
        blockingRef.child(currentUser.uid).child(poem.userUID).setValue(UUID().uuidString)
        
        poemRef.child(poem.userUID).observeSingleEvent(of: .value) { snapshot in
            
            let allPoems = snapshot.value as? [String:Any] ?? [:]
            
            for poem in allPoems {

                let poemDic = poem.value as! [String:Any]

                poemRef.child(poemDic["userUID"]! as! String).child(poemDic["id"]! as! String).runTransactionBlock { currentData in
                    if var updatedPoem = currentData.value as? [String:Any] {
                        var reportedUser = updatedPoem["reportedUsers"] as? [String:Bool] ?? [:]
                        reportedUser[currentUser.uid] = true
                        updatedPoem["reportedUsers"] = reportedUser
                        currentData.value = updatedPoem
                        return TransactionResult.success(withValue: currentData)
                    }
                    return TransactionResult.success(withValue: currentData)
                }
                
            }
            completion()
        }
    }
}
