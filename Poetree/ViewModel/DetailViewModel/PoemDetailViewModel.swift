//
//  ReadPoemViewModel.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/11.
//

import Foundation
import RxSwift
import RxCocoa

class PoemDetailViewModel: ViewModelType {
    
    let poemService: PoemService
    let userService: UserService
    
    
    struct Input {
        
    }
    
    struct Output {
        let displayingPoem: Driver<Poem>
        let isTempDetail: Bool
    }
    
    var input: Input
    var output: Output
    
    init(poem: Poem, poemService: PoemService, userService: UserService, isTempDetail: Bool = false) {
        
        self.poemService = poemService
        self.userService = userService
        
        let poems = poemService.allPoems()
        
        let displayingPoem = poems.map{poems in poemService.fetchMatchedPoem(poems: poems, poem: poem)}
            .asDriver(onErrorJustReturn: poem)
        
        self.input = Input()
        self.output = Output(displayingPoem: displayingPoem, isTempDetail: isTempDetail)
    }
    
    func deletePoem(deletingPoem: Poem) {
        poemService.deletePoem(deletingPoem: deletingPoem)
    }
}
