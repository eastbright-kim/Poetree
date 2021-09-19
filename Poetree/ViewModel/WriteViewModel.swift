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
        let writingType: WritingType
        let editingPoem: Poem?
        let isFromMain: Bool
    }
    
    var input: Input
    var output: Output
    
    init(poemService: PoemService, userService: UserService, writingType: WritingType, editingPoem: Poem? = nil, isFromMain: Bool = false) {
        
        self.poemService = poemService
        self.userService = userService
        let title = BehaviorSubject<String>(value: "")
        let content = BehaviorSubject<String>(value: "")
        let isPrivate = BehaviorSubject<Bool>(value: false)
        let currentUser = userService.loggedInUser()
        
        
        let aPoem = Observable<Poem>.combineLatest(title, content, isPrivate, currentUser) { title, content, isPrivate, currentAuth in
      
            switch writingType {
            case .write(let weekPhoto):
                return Poem(id: UUID().uuidString, userEmail: currentAuth.userEmail, userNickname: currentAuth.userPenname, title: title, content: content, photoId: weekPhoto.id, uploadAt: Date(), isPrivate: isPrivate, likers: [:], photoURL: weekPhoto.url, userUID: currentAuth.userUID, isTemp: false)
            case .edit(let editingPoem):
                return Poem(id: editingPoem.id, userEmail: currentAuth.userEmail, userNickname: currentAuth.userPenname, title: title, content: content, photoId: editingPoem.photoId, uploadAt: editingPoem.uploadAt, isPrivate: isPrivate, likers: editingPoem.likers, photoURL: editingPoem.photoURL, userUID: currentAuth.userUID, isTemp: editingPoem.isTemp)
            case .temp(let writingPoem):
                return Poem(id: writingPoem.id, userEmail: currentAuth.userEmail, userNickname: currentAuth.userPenname, title: title, content: content, photoId: writingPoem.photoId, uploadAt: Date(), isPrivate: isPrivate, likers: [:], photoURL: writingPoem.photoURL, userUID: currentAuth.userUID, isTemp: writingPoem.isTemp)
            }
        }
        
        self.input = Input(title: title, content: content, isPrivate: isPrivate)
        self.output = Output(aPoem: aPoem, writingType: writingType, editingPoem: editingPoem, isFromMain: isFromMain)
        
    }
}

enum WritingType {
    
    case write(WeekPhoto)
    case edit(Poem)
    case temp(Poem)
}
