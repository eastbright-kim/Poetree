//
//  Error.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/14.
//

import Foundation


enum Complete: String {
   
    case writedPoem = "시 쓰기 성공"
    case fetchedPoem = "전체 시 불러오기 성공"
}


enum Errors: String, Error {
    
    case emailError = "시 쓰기 에러 발생"
    case userRegisterError = "유저 등록 에러 발생"
    case userExists = "유저 이메일 기등록 상태"
}
