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
    
    struct Input {
        
//        let isLike: BehaviorSubject<Bool>
        
    }
    
    struct Output {
        
    }
    
    var input: Input
    var output: Output
    
    init(poemService: PoemService) {
        self.poemService = poemService
        
        self.input = Input()
        self.output = Output()
    }
}
