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
        let displayingPoem: Poem
    }
    
    var input: Input
    var output: Output
    
    init(displayingPoem: Poem, poemService: PoemService, userService: UserService) {
        
        self.poemService = poemService
        self.userService = userService
        
        self.input = Input()
        self.output = Output(displayingPoem: displayingPoem)
    }
    
    func deletePoem(deletingPoem: Poem) {
        poemService.deletePoem(deletingPoem: deletingPoem)
    }
}
