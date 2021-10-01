//
//  PoemListViewModel.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/11.
//

import Foundation
import RxSwift
import Firebase

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
        
        let poems = poemService.allPoems()
        
        
        switch listType {
        case .allPoems:
            let displayingPoems = poems.map(poemService.filterPoemsForPublic).map(poemService.filterBlockedPoem).map(poemService.sortPoemsByLikeCount_Random)
            self.output = Output(displayingPoems: displayingPoems, listType: listType)
        case .thisWeek:
            let thisWeekPoems = poems.map(poemService.filterPoemsForPublic).map(poemService.filterBlockedPoem).map(poemService.fetchThisWeekPoems).map(poemService.sortPoemsByLikeCount_Random)
            self.output = Output(displayingPoems: thisWeekPoems, listType: listType)
        case .userLiked(let currentAuth):
            let displayingPoems = poems
                .map { poems in poemService.fetchUserLikedWriting_Sorted(poems: poems, currentUser: currentAuth)}
                .map(poemService.filterBlockedPoem)
            self.output = Output(displayingPoems: displayingPoems, listType: listType)
        case .userWrote(let currentAuth):
            let displayingPoems = poems
                .map { poems in poemService.fetchUserWriting(poem: poems, currentUser: currentAuth)}
                .map(poemService.filterBlockedPoem)
                .map(poemService.sortPoemsByLikeCount_Recent)
            self.output = Output(displayingPoems: displayingPoems, listType: listType)
        case .tempSaved(let currentUser):
            let displayingPoems = poems
                .map { poems in
                    poemService.fetchTempSaved(poems: poems, currentUser: currentUser)
                }
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
    case tempSaved(User)
}
