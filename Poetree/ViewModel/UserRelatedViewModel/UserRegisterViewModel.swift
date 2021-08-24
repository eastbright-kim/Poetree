//
//  UserRegisterViewModel.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/14.
//

import Foundation
import RxSwift
import RxCocoa

class UserRegisterViewModel: ViewModelType {
    
    let userService: UserService!
    
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    
    var input: Input
    var output: Output
    
    
    init(userService: UserService){
        
        self.userService = userService
        
        self.input = Input()
        self.output = Output()
    }
    
}
