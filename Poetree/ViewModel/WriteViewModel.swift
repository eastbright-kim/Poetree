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

class WriteViewModel: ViewModelType {
    
    
    let poemService: PoemService
    
    
    struct Input {
        
        let title: BehaviorSubject<String>
        let content: BehaviorSubject<String>
        var isPrivate: BehaviorSubject<Bool>
        
    }
    
    struct Output {
        let photoDisplayed: URL
        let getCurrentDate: Driver<String>
        let aPoem: Observable<Poem>
        let editingPoem: Poem?
    }
    
    var input: Input
    var output: Output
    
    init(weekPhoto: WeekPhoto?, poemService: PoemService, editingPoem: Poem?) {
        self.poemService = poemService
        
        
        let getCurrentDate =  Observable<String>.just(poemService.getCurrentWritingTime())
            .asDriver(onErrorJustReturn: "좋은 날")
        
        print(editingPoem!.title)
        let title = BehaviorSubject<String>(value: editingPoem?.title ?? "")
        let content = BehaviorSubject<String>(value: "")
        let isPrivate = BehaviorSubject<Bool>(value: false)
        
        let user = Auth.auth().currentUser!
        
        
        
        let aPoem = Observable<Poem>.combineLatest(title, content, isPrivate) { newTitle, content, isPrivate in
            print(title)
            if let weekPhoto = weekPhoto {
                return Poem(id: user.uid, userEmail: user.email ?? "noEmail", userNickname: user.displayName ?? "noNickname", title: newTitle, content: content, photoId: weekPhoto.id, uploadAt: Date(), isPrivate: isPrivate, likers: [:], photoURL: weekPhoto.url)
            } else {
                print(newTitle)
                print(content)
                return Poem(id: user.uid, userEmail: user.email ?? "noEmail", userNickname: user.displayName ?? "noNickname", title: newTitle, content: content, photoId: editingPoem!.photoId, uploadAt: Date(), isPrivate: isPrivate, likers: [:], photoURL: editingPoem!.photoURL)
            }
        }
        .debug()
        
        if let weekPhoto = weekPhoto {
            self.input = Input(title: title, content: content, isPrivate: isPrivate)
            self.output = Output(photoDisplayed: weekPhoto.url, getCurrentDate: getCurrentDate, aPoem: aPoem, editingPoem: nil)
        } else {
            self.input = Input(title: title, content: content, isPrivate: isPrivate)
            self.output = Output(photoDisplayed: editingPoem!.photoURL, getCurrentDate: getCurrentDate, aPoem: aPoem, editingPoem: editingPoem!)
        }
    }
    func createPeom(poem: Poem) {
        poemService.createPoem(poem: poem) { result in
            print(result)
        }
    }
    
    func editePoem(editedPoem: Poem) {
        print(editedPoem.title)
        poemService.editPoem(editedPoem: editedPoem) { result in
            self.poemService.poemForDetailView.onNext(editedPoem)
            print(result)
        }
    }
}
