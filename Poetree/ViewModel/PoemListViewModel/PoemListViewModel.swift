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
        let listType: PoemListType
    }
    
    var input: Input
    var output: Output
    
    init(poemService: PoemService, userService: UserService, listType: PoemListType, selectedPhotoId: Int? = nil) {
        
        switch listType {
        case .allPoems:
            let displayingPoems = poemService.allPoems()
                .map(poemService.sortPoemsByLikeCount_random)
            self.output = Output(displayingPoems: displayingPoems, listType: listType)
        case .thisWeek:
            let thisWeekPoems = poemService.fetchThisWeekPoems()
            let displayingPoems = Observable.just(thisWeekPoems)
                .map(poemService.sortPoemsByLikeCount_random)
            self.output = Output(displayingPoems: displayingPoems, listType: listType)
        case .userLiked(let currentAuth):
            let displayingPoems = poemService.allPoems()
                .map { poems in poemService.fetchUserLikedWriting(poems: poems, currentUser: currentAuth)}
            self.output = Output(displayingPoems: displayingPoems, listType: listType)
        case .userWrote(let currentAuth):
            let displayingPoems = poemService.allPoems()
                .map { poems in poemService.fetchUserWriting(poem: poems, currentUser: currentAuth)}
                .map(poemService.sortPoemsByLikeCount_random)
            self.output = Output(displayingPoems: displayingPoems, listType: listType)
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
