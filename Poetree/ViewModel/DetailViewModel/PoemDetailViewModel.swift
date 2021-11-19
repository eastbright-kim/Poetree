//
//  ReadPoemViewModel.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/11.
//

import UIKit
import RxSwift
import RxCocoa

class PoemDetailViewModel: ViewModelType {
    
    let poemService: PoemService
    let userService: UserService
    let displayingPoem: Driver<Poem>
    let isTempDetail: Bool
    let isUserWriting: Bool
    var deleteAction: (()-> Void) = {}
    
    
    struct Input {
        
    }
    
    struct Output {

    }
    
    var input: Input
    var output: Output
    
    init(poem: Poem, poemService: PoemService, userService: UserService, isTempDetail: Bool = false, isUserWriting: Bool = false) {
        
        self.poemService = poemService
        self.userService = userService
        let poems = poemService.allPoems()
        self.displayingPoem = poems.map{poems in poemService.fetchEditedPoem(poems: poems, poem: poem)}
            .asDriver(onErrorJustReturn: poem)
        self.isTempDetail = isTempDetail
        self.isUserWriting = isUserWriting
        
        self.input = Input()
        self.output = Output()
    }
    
}
