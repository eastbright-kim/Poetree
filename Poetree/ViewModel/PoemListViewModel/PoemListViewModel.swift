//
//  PoemListViewModel.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/11.
//

import Foundation
import RxSwift


class PoemListViewModel: ViewModelType {
    
    let poemService: PoemService
    
    struct Input {
        
    }
    
    struct Output {
        let allPoems: Observable<[Poem]>
    }
    
    var input: Input
    var output: Output
    
    init(poemService: PoemService) {
        
        poemService.fetchPoems { poems, result in
            print(result)
        }
        
        let allPoems = poemService.allPoems()
        
        self.poemService = poemService
        self.input = Input()
        self.output = Output(allPoems: allPoems)
    }
}
