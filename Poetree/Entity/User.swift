//
//  User.swift
//  Poetree
//
//  Created by 김동환 on 2021/09/05.
//

import Foundation

struct UserEntity: Equatable {
    
    let email: String
    let uid: String
    let penname: String
    
    
    init(userDic: [String:String]){
        
        self.email = userDic["email"] ?? ""
        self.uid = userDic["uid"] ?? ""
        self.penname = userDic["penname"] ?? ""
    }
    
}
