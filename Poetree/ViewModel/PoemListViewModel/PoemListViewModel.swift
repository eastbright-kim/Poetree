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
    let userService: UserService
    struct Input {
        
    }
    
    struct Output {
        let displayingPoems: Observable<[Poem]>
    }
    
    var input: Input
    var output: Output
    
    init(poemService: PoemService, userService: UserService, listType: PoemListType, selectedPhotoId: Int? = nil) {
        
        switch listType {
        
        case .allPoems:
            let displayingPoems = poemService.allPoems()
            self.output = Output(displayingPoems: displayingPoems)
        case .thisWeek:
            let thisWeekPoems = poemService.fetchThisWeekPoems()
            let displayingPoems = Observable.just(thisWeekPoems)
            self.output = Output(displayingPoems: displayingPoems)
        case .userLiked(let currentAuth):
            let displayingPoems = poemService.allPoems()
                .map { poems in poemService.fetchUserLikedWriting(poems: poems, currentUser: currentAuth)}
            self.output = Output(displayingPoems: displayingPoems)
        case .userWrote(let currentAuth):
            let displayingPoems = poemService.allPoems()
                .map { poems in poemService.fetchUserWriting(poem: poems, currentUser: currentAuth)}
            self.output = Output(displayingPoems: displayingPoems)
            
        }
        self.poemService = poemService
        self.userService = userService
        self.input = Input()
    }
}

enum PoemListType {
    case allPoems
    case thisWeek
    case userLiked(CurrentAuth)
    case userWrote(CurrentAuth)
}
