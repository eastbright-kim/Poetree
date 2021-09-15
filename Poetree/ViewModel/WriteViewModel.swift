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
        var isTemporarySaved: BehaviorSubject<Bool>
    }
    
    struct Output {
      
        let aPoem: Observable<Poem>
        let writingType: WritingType
        let editingPoem: Poem?
    }
    
    var input: Input
    var output: Output
    
    init(poemService: PoemService, userService: UserService, writingType: WritingType, editingPoem: Poem? = nil) {
        
        self.poemService = poemService
        self.userService = userService
        let title = BehaviorSubject<String>(value: "")
        let content = BehaviorSubject<String>(value: "")
        let isPrivate = BehaviorSubject<Bool>(value: false)
        let currentUser = userService.loggedInUser()
        let isTemporarySaved = BehaviorSubject<Bool>(value: false)
        
        let aPoem = Observable<Poem>.combineLatest(title, content, isPrivate, currentUser, isTemporarySaved) { title, content, isPrivate, currentAuth, isTemporarySaved in
      
            switch writingType {
            
            case .write(let weekPhoto):
                
                return Poem(id: UUID().uuidString, userEmail: currentAuth.userEmail, userNickname: currentAuth.userPenname, title: title, content: content, photoId: weekPhoto.id, uploadAt: Date(), isPrivate: isPrivate, likers: [:], photoURL: weekPhoto.url, userUID: currentAuth.userUID, isTemporarySaved: isTemporarySaved)
                
            case .edit(let editingPoem):
                
                return Poem(id: editingPoem.id, userEmail: currentAuth.userEmail, userNickname: currentAuth.userPenname, title: title, content: content, photoId: editingPoem.photoId, uploadAt: editingPoem.uploadAt, isPrivate: isPrivate, likers: [:], photoURL: editingPoem.photoURL, userUID: currentAuth.userUID, isTemporarySaved: isTemporarySaved)
            
            }
        }
        
        self.input = Input(title: title, content: content, isPrivate: isPrivate, isTemporarySaved: isTemporarySaved)
        self.output = Output(aPoem: aPoem, writingType: writingType, editingPoem: editingPoem)
        
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

enum WritingType {
    
    case write(WeekPhoto)
    case edit(Poem)
    
}
