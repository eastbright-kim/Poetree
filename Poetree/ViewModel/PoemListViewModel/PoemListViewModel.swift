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
        let displayingPoems: Observable<[Poem]>
    }
    
    var input: Input
    var output: Output
    
    init(poemService: PoemService, listType: PoemListType, selectedPhotoId: Int? = nil) {
        
        switch listType {
        case .allPoems:
            let displayingPoems = poemService.allPoems()
            self.output = Output(displayingPoems: displayingPoems)
        case .thisWeek:
            let thisWeekPoems = poemService.fetchThisWeekPoems()
            let displayingPoems = Observable.just(thisWeekPoems)
            self.output = Output(displayingPoems: displayingPoems)
        case .seletedPhoto:
            let displayingPoems = poemService.allPoems()
                .map { poems -> [Poem] in
                    let selected = poems.filter { poem in
                        poem.photoId == selectedPhotoId
                    }
                    return selected
                }
            self.output = Output(displayingPoems: displayingPoems)
        }
        self.poemService = poemService
        self.input = Input()
    }
}

enum PoemListType {
    case allPoems
    case thisWeek
    case seletedPhoto
    //    case UserLiked
    //    case UserWrote
}
