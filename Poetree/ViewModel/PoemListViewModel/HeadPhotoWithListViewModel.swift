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
        var weekPhoto: WeekPhoto
    }
    
    init(poemService: PoemService, userService: UserService, weekPhoto: WeekPhoto){
        
       
        self.poemService = poemService
        self.userService = userService
        let poems = poemService.allPoems()
        
        let displayingPoem = poems.map { poems in
            poemService.fetchPoemsByPhotoId(poems: poems, weekPhoto: weekPhoto)
        }
        
        
        self.input = Input()
        self.output = Output(displayingPoem: displayingPoem, weekPhoto: weekPhoto)
    }
}
