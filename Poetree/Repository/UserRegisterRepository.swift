//
//  UserRegisterRepository.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/24.
//

import Foundation
import Firebase


class UserRegisterRepository{
    
    var delegate: UserLogInListener?
    
    init(delegate: UserLogInListener) {
        self.delegate = delegate
    }
    
    // 기존의 사용자가 penname을 바꾸는 경우 or 처음 가입하는 경우
    func RegisterToFirebase(penname: String, credential: AuthCredential, completion: @escaping ((Result<CurrentAuth, RegisterError>) -> Void)){
        
        Auth.auth().signIn(with: credential) { authDataResult, error in
            
            Auth.auth().addStateDidChangeListener { (auth, user) in
                
                guard let currentUser = auth.currentUser else { completion(.failure(.flatFormError))
                    return }
                
                let changeRequest = currentUser.createProfileChangeRequest()
                
                changeRequest.displayName = penname
                changeRequest.commitChanges { error in
                    if let _ = error {
                        completion(.failure(.registerError))
                    } else {
                        
                        if let email = currentUser.email {
                            let currentAuth = CurrentAuth(userEmail: email, userPenname: currentUser.displayName ?? "회원", userUID: currentUser.uid)
                            
                            if let delegate = self.delegate {
                                delegate.updatePenname(userResisterRepository: self, logInUser: currentAuth)
                            }
                            
                            completion(.success(currentAuth))
                        } else {
                            let currentAuth = CurrentAuth(userEmail: currentUser.uid, userPenname: currentUser.displayName ?? "회원", userUID: currentUser.uid)
                            
                            if let delegate = self.delegate {
                                delegate.updatePenname(userResisterRepository: self, logInUser: currentAuth)
                            }
                            
                            completion(.success(currentAuth))
                        }
                    }
                }
            }
        }
    }
    
    
    func firebaseLogIn(credential: AuthCredential,  completion: @escaping ((Result<CurrentAuth, LoginError>) -> Void)){
        
        Auth.auth().signIn(with: credential) { authDataResult, error in
            
            if let isNew = authDataResult?.additionalUserInfo?.isNewUser {
                if isNew == true {
                    completion(.failure(.newUser))
                    return
                }
            }
            
            Auth.auth().addStateDidChangeListener { auth, user in
                
                if let currentUser = auth.currentUser {
                    let currentAuth = CurrentAuth(userEmail: currentUser.email ?? "unknowned", userPenname: currentUser.displayName ?? "unknowned", userUID: currentUser.uid)
                    completion(.success(currentAuth))
                } else {
                    completion(.failure(.flatFormError))
                }
            }
        }
    }
    
    func fetchNotices(completion: @escaping ([NoticeEntity]) -> Void){
        
        noticeRef.observeSingleEvent(of: .value) { snapshot in
            
            let value = snapshot.value as? [String:Any] ?? [:]
            
            var noticeEntity = [NoticeEntity]()
            
            for value in value.values {
                let dic = value as! [String : String]
                let notice = NoticeEntity(noticeDic: dic)
                noticeEntity.append(notice)
            }
            completion(noticeEntity)
        }
    }
}
