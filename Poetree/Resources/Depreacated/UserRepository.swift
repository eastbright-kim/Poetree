//
//  UserRepository.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/14.
//

import Foundation
import FirebaseAuth

class UserRepository {
    
    
    func userRegister(userInput: User, completion: @escaping ((Result<String, UserError>) -> Void)){
        
        Auth.auth().createUser(withEmail: userInput.email, password: userInput.password) { result, error in
            
            guard result != nil, error == nil else {
                print("이메일 등록 오류")
                completion(.failure(.emailError))
                return }
            
            Auth.auth().addStateDidChangeListener { (auth, user) in
                guard let currentUser = auth.currentUser else { return }
                let changeRequest = currentUser.createProfileChangeRequest()
                changeRequest.displayName = userInput.penName
                changeRequest.commitChanges { error in
                    if let error = error {
                        print("필명 등록 에러 : \(error.localizedDescription)")
                        completion(.failure(.penNameError))
                    } else {
                        print("필명 정상 등록")
                        completion(.success("Poetree 가입을 환영합니다 :)"))
                    }
                }
            }
        }
    }
}
