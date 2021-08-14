//
//  MyPoemViewModel.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/11.
//

import Foundation

class MyPoemViewModel: ViewModelType {
    
    let poemService: PoemService!
    
    let userService: UserService!
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    var input: Input
    var output: Output
    
    init(poemService: PoemService, userServie: UserService) {
        self.input = Input()
        self.output = Output()
        self.poemService = poemService
        self.userService = userServie
    }
}
