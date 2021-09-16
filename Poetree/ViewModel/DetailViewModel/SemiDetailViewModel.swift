//
//  SemiDetailViewModel.swift
//  Poetree
//
//  Created by 김동환 on 2021/09/08.
//

import Foundation
import RxSwift
import RxCocoa

class SemiDetailViewModel: ViewModelType {
    
    var input: Input
    var output: Output
    
    let poemService: PoemService
    let userService: UserService
    
    struct Input{
        
    }
    
    struct Output{
        let displayingPoem: Driver<Poem>
    }
    
    
    init(poem: Poem, poemService: PoemService, userService: UserService){
        
        self.poemService = poemService
        self.userService = userService
        
        let poems = poemService.allPoems()
        
        let displayingPoem = poems.map{poems in poemService.fetchPoem(poems: poems, poem: poem)}
            .asDriver(onErrorJustReturn: poem)
        
        self.input = Input()
        self.output = Output(displayingPoem: displayingPoem)
    }
}
