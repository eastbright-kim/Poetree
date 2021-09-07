//
//  Error.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/14.
//

import Foundation
import Firebase

enum Complete: String {
   
    case writedPoem = "시 쓰기 성공"
    case fetchedPoem = "전체 시 불러오기 성공"
}

enum SignInErorr: Error {
    case LoginError(LoginError)
    case RegisterError(RegisterError)
}

enum RegisterError: Error {
    case flatFormError
    case registerError
}

enum LoginError: Error {
    
    case newUser
    case logInError
    case flatFormError
    
}
