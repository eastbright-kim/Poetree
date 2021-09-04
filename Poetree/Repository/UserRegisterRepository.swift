//
//  UserRegisterRepository.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/24.
//

import Foundation
import Firebase


class UserRegisterRepository{
    
    static let shared = UserRegisterRepository()
    var emails = [String]()
    
    func fetchUserUID() {
        
        userRef.observeSingleEvent(of: .value) { snapshot in
            
            let uids = snapshot.value as? [String:String] ?? [:]
            
            for email in uids.values {
                self.emails.append(email)
            }
        }
    }
    
    func RegisterToFirebase(penname: String, flatform: FlatFormType, completion: @escaping ((Result<CurrentUser, Errors>) -> Void)){
        
        
        switch flatform {
        case .Google_Facebook(let credential):
            Auth.auth().signIn(with: credential) { authDataResult, error in
                
                Auth.auth().addStateDidChangeListener { (auth, user) in
                    
                    guard let currentUser = auth.currentUser else { return }
                    userRef.child(currentUser.uid).setValue(currentUser.email)
                    if self.checkRegisterValid(email: currentUser.email!) {
                        completion(.failure(.userExists))
                        return
                    }
                    
                    
                    let changeRequest = currentUser.createProfileChangeRequest()
                    changeRequest.displayName = penname
                    changeRequest.commitChanges { error in
                        if let error = error {
                            print("닉네임 등록 에러 : \(error.localizedDescription)")
                            completion(.failure(.userRegisterError))
                        } else {
                            print("닉네임 정상 등록")
                            let currentUser = CurrentUser(userEmail: currentUser.email!, userPenname: currentUser.displayName!, userUID: currentUser.uid)
                            
                            completion(.success(currentUser))
                        }
                    }
                }
            }
        case .Apple(let credential):
            Auth.auth().signIn(with: credential) { authDataResult, error in
                Auth.auth().addStateDidChangeListener { (auth, user) in
                    
                    guard let currentUser = auth.currentUser else { return }
                    
                    userRef.child(currentUser.uid).setValue(currentUser.email)
                    if self.checkRegisterValid(email: currentUser.email!) {
                        completion(.failure(.userExists))
                        return
                    }

                    let changeRequest = currentUser.createProfileChangeRequest()
                    changeRequest.displayName = penname
                    changeRequest.commitChanges { error in
                        if let error = error {
                            print("닉네임 등록 에러 : \(error.localizedDescription)")
                            completion(.failure(.userRegisterError))
                        } else {
                            print("닉네임 정상 등록")
                            let currentUser = CurrentUser(userEmail: currentUser.email!, userPenname: currentUser.displayName!, userUID: currentUser.uid)
                            completion(.success(currentUser))
                        }
                    }
                }
            }
        }
    }
    
    func checkRegisterValid(email: String) -> Bool {
        
        return self.emails.contains(email)
    }
    
}


enum FlatFormType{
    case Google_Facebook(AuthCredential)
    case Apple(OAuthCredential)
}
