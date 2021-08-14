//
//  Error.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/14.
//

import Foundation


enum UserError: String, Error {
    
    case emailError = "이미 존재하는 이메일 입니다."
    case penNameError = "필명 등록 오류가 발생했습니다."
    
}
