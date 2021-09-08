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
    let poem: Poem
    let poemService: PoemService
    
    struct Input{
        
    }
    
    struct Output{
        
    }
    
    
    init(poem: Poem, poemService: PoemService){
        self.poem = poem
        self.poemService = poemService
        self.input = Input()
        self.output = Output()
    }
    
}
