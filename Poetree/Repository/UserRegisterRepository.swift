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
                        let currentAuth = CurrentAuth(userEmail: currentUser.email!, userPenname: currentUser.displayName!, userUID: currentUser.uid)
                        
                        completion(.success(currentAuth))
                    }
                }
            }
        }
    }
    
    // 처음 사용자가 login하는 경우 or 기존 사용자가 login하는 경우
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
}
