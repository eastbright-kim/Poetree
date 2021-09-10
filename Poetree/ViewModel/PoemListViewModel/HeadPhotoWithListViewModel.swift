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
        var weekPhoto: WeekPhoto?
    }
    
    init(poemService: PoemService, userService: UserService, weekPhoto: WeekPhoto? = nil, listType: ListType){
        
       
        self.poemService = poemService
        self.userService = userService
        let poems = poemService.allPoems()
        var displayingPoem = BehaviorSubject<[Poem]>(value: []).asObservable()
        
        
        switch listType {
        
        case .fromDisplayingPoem(let getPoems):
            displayingPoem = getPoems
            
            
        case .weekPhoto(let weekPhoto):
            let getPoems = poems.map { poems in
                poemService.fetchPoemsByPhotoId(poems: poems, weekPhoto: weekPhoto)
            }
            displayingPoem = getPoems
        }
        
        self.input = Input()
        self.output = Output(displayingPoem: displayingPoem, weekPhoto: weekPhoto)
    }
}

enum ListType {
    
    case fromDisplayingPoem(Observable<[Poem]>)
    case weekPhoto(WeekPhoto)
    
}
