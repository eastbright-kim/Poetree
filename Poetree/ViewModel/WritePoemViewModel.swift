//
//  WritePoemViewModel.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/11.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseAuth

class WritePoemViewModel: ViewModelType {
    
    
    let poemService: PoemService
    
    
    struct Input {
        
        let title: BehaviorSubject<String>
        let content: BehaviorSubject<String>
        var isPublic: BehaviorSubject<Bool>
        
    }
    
    struct Output {
        let photoDisplayed: URL
        let getCurrentDate: Driver<String>
        let aPoem: Observable<Poem>
    }
    
    var input: Input
    var output: Output
    
    init(weekPhoto: WeekPhoto, poemService: PoemService) {
        self.poemService = poemService
       
        
        let getCurrentDate =  Observable<String>.just(poemService.getCurrentWritingTime())
            .asDriver(onErrorJustReturn: "좋은 날")
        
        let title = BehaviorSubject<String>(value: "")
        let content = BehaviorSubject<String>(value: "")
        let isPublic = BehaviorSubject<Bool>(value: true)
        
        let user = Auth.auth().currentUser!
        
        
        let aPoem = Observable<Poem>.combineLatest(title, content, isPublic) { title, content, isPublic in
            
            return Poem(id: user.uid, userEmail: user.email ?? "noEmail", userNickname: user.displayName ?? "noNickname", title: title, content: content, photoId: weekPhoto.id, uploadAt: Date(), isPublic: isPublic, likers: [:], photoURL: weekPhoto.url)
        }
        
        self.input = Input(title: title, content: content, isPublic: isPublic)
        self.output = Output(photoDisplayed: weekPhoto.url, getCurrentDate: getCurrentDate, aPoem: aPoem)
    }
    
    func createPeom(poem: Poem) {
        poemService.createPoem(poem: poem) { result in
            print(result)
        }
    }
}
