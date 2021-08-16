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
//        
//        let photoURL: URL
//        let title: Driver<String>
//        let user: Driver<String>
//        let content: Driver<String>
//        let isLike: BehaviorSubject<Bool>
    }
    
    var input: Input
    var output: Output
    
    init(poem: Poem, poemService: PoemService) {
        
        self.poemService = poemService
        
        let imageURL = poem.photoURL
        let title = BehaviorSubject<String>(value: poem.title)
            .asDriver(onErrorJustReturn: "")
        let content = BehaviorSubject<String>(value: poem.content)
            .asDriver(onErrorJustReturn: "")
        let userLabel = "\(poem.userNickname)님이 \(convertDateToString(format: "MMM d", date: poem.uploadAt))에 보낸 글"
        
//
//
//        poemService.updatePoem
//            .subscribe(onNext: poem in
//                       title.onNext(poem)
//
//            )
//
//
        
        self.input = Input()
        self.output = Output()
    }
}
