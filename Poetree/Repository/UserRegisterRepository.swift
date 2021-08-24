//
//  UserRegisterRepository.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/24.
//

import Foundation
import Firebase


class UserRegisterRepository{
    
    
    func RegisterToFirebase(penname: String, flatform: FlatFormType, completion: @escaping ((Bool) -> Void)){
        
        switch flatform {
        case .Google_Facebook(let credential):
            Auth.auth().signIn(with: credential) { authDataResult, error in
                Auth.auth().addStateDidChangeListener { (auth, user) in
                    guard let currentUser = auth.currentUser else { return }
                    let changeRequest = currentUser.createProfileChangeRequest()
                    changeRequest.displayName = penname
                    changeRequest.commitChanges { error in
                        if let error = error {
                            print("닉네임 등록 에러 : \(error.localizedDescription)")
                            completion(false)
                        } else {
                            print("닉네임 정상 등록")
                            completion(true)
                        }
                    }
                }
            }
        case .Apple(let credential):
            Auth.auth().signIn(with: credential) { authDataResult, error in
                
                Auth.auth().addStateDidChangeListener { (auth, user) in
                    guard let currentUser = auth.currentUser else { return }
                    let changeRequest = currentUser.createProfileChangeRequest()
                    changeRequest.displayName = penname
                    changeRequest.commitChanges { error in
                        if let error = error {
                            print("닉네임 등록 에러 : \(error.localizedDescription)")
                            completion(false)
                        } else {
                            print("닉네임 정상 등록")
                            completion(true)
                        }
                    }
                }
            }
        }
    }
}


enum FlatFormType{
    case Google_Facebook(AuthCredential)
    case Apple(OAuthCredential)
}
