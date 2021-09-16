//
//  SemiDetailViewModel.swift
//  Poetree
//
//  Created by 김동환 on 2021/09/08.
//

import Foundation

class SemiDetailViewModel: ViewModelType {
    
    var input: Input
    var output: Output
    
    let poemService: PoemService
    let userService: UserService
    
    struct Input{
        
    }
    
    struct Output{
        let poem: Poem
    }
    
    
    init(poem: Poem, poemService: PoemService, userService: UserService){
        
        self.poemService = poemService
        self.userService = userService
        
        
        self.input = Input()
        self.output = Output(poem: poem)
    }
    
}
