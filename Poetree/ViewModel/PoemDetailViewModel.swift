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
        
        let aPoem: Driver<Poem>
        let user_date: String

    }
    
    var input: Input
    var output: Output
    
    init(poem: Poem, poemService: PoemService) {
        
        self.poemService = poemService
        
       
        let aPoem = poemService.onePoemForDetailView()
            .asDriver(onErrorJustReturn: Poem(id: "", userEmail: "", userNickname: "", title: "", content: "", photoId: 0, uploadAt: Date(), isPrivate: true, likers: [:], photoURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/poetree-e472e.appspot.com/o/white%2F2-2.jpg?alt=media&token=3945142a-4a01-431b-9a0c-51ff8ee10538")!))
        
        let userLabel = "\(poem.userNickname)님이 \(convertDateToString(format: "MMM d", date: poem.uploadAt))에 보낸 글"
        
        

        self.input = Input()
        self.output = Output(aPoem: aPoem, user_date: userLabel)
    }
}
