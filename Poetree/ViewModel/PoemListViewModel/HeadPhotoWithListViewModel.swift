//
//  HeadPhotoWithListViewModel.swift
//  Poetree
//
//  Created by 김동환 on 2021/09/09.
//

import Foundation
import RxSwift
import RxCocoa

class HeadPhotoWithListViewModel: ViewModelType {
    
    var input: Input
    var output: Output
    
    let poemService: PoemService
    let userService: UserService
    
    struct Input{
        
    }
    
    struct Output {
        var displayingPoem: Observable<[Poem]>
        
    }
    
    init(poemService: PoemService, displayingPoem: Observable<[Poem]>, userService: UserService){
        
       
        self.poemService = poemService
        self.userService = userService
        
        
        self.input = Input()
        self.output = Output(displayingPoem: displayingPoem)
    }
}
