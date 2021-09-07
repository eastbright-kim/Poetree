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
    let userService: UserService
    
    struct Input {
        let title: BehaviorSubject<String>
        let content: BehaviorSubject<String>
        var isPrivate: BehaviorSubject<Bool>
    
    }
    
    struct Output {
      
        let aPoem: Observable<Poem>
        let weekPhoto: WeekPhoto?
    }
    
    var input: Input
    var output: Output
    
    init(poemService: PoemService, userService: UserService, weekPhoto: WeekPhoto? = nil, editingPoem: Poem? = nil) {
        self.poemService = poemService
        self.userService = userService
        let title = BehaviorSubject<String>(value: "")
        let content = BehaviorSubject<String>(value: "")
        let isPrivate = BehaviorSubject<Bool>(value: false)
        let currentUser = userService.loggedInUser()
        
        
        let aPoem = Observable<Poem>.combineLatest(title, content, isPrivate, currentUser) { title, content, isPrivate, currentAuth in
      
            if let weekPhoto = weekPhoto {
                
                return Poem(id: UUID().uuidString, userEmail: currentAuth.userEmail, userNickname: currentAuth.userPenname, title: title, content: content, photoId: weekPhoto.id, uploadAt: Date(), isPrivate: isPrivate, likers: [:], photoURL: weekPhoto.url, userUID: currentAuth.userUID)
            } else {
                return Poem(id: editingPoem!.id, userEmail: currentAuth.userEmail, userNickname: currentAuth.userPenname, title: title, content: content, photoId: editingPoem!.photoId, uploadAt: Date(), isPrivate: isPrivate, likers: [:], photoURL: editingPoem!.photoURL, userUID: currentAuth.userUID)
            }
        }
        
        self.input = Input(title: title, content: content, isPrivate: isPrivate)
        self.output = Output(aPoem: aPoem, weekPhoto: weekPhoto)
        
    }
    
    
    func createPoem(poem: Poem) {
        poemService.createPoem(poem: poem) { result in
            print(result)
        }
    }
    
    func editPoem(beforeEdited: Poem, editedPoem: Poem) {
        
        poemService.editPoem(beforeEdited: beforeEdited, editedPoem: editedPoem) { result in
            
            print(result)
        }
    }
    
}
