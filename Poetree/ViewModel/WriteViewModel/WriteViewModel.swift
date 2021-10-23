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
    let beforeEditedPoem: Poem?
    let writingType: WritingType
    let isFromMain: Bool
    
    struct Input {
        let title: BehaviorSubject<String>
        let content: BehaviorSubject<String>
        var isPrivate: BehaviorSubject<Bool>
    }
    
    struct Output {
        let aPoem: Observable<Poem>
    }
    
    var input: Input
    var output: Output
    
    init(poemService: PoemService, userService: UserService, writingType: WritingType, beforeEditedPoem: Poem? = nil, isFromMain: Bool = false) {
        
        self.poemService = poemService
        self.userService = userService
        self.beforeEditedPoem = beforeEditedPoem
        self.writingType = writingType
        self.isFromMain = isFromMain
        let title = BehaviorSubject<String>(value: "")
        let content = BehaviorSubject<String>(value: "")
        let isPrivate = BehaviorSubject<Bool>(value: false)
        let currentUser = userService.fetchLoggedInUser()
        
        let aPoem = Observable<Poem>.combineLatest(title, content, isPrivate, currentUser) { title, content, isPrivate, currentAuth in
            switch writingType {
            case .write(let weekPhoto):
                return Poem(id: UUID().uuidString, userEmail: currentAuth.userEmail, userNickname: currentAuth.userPenname, title: title, content: content, photoId: weekPhoto.id, uploadAt: Date(), isPrivate: isPrivate, likers: [:], photoURL: weekPhoto.url, userUID: currentAuth.userUID, isTemp: false, isBlocked: false)
            case .edit(let editingPoem):
                return Poem(id: editingPoem.id, userEmail: currentAuth.userEmail, userNickname: currentAuth.userPenname, title: title, content: content, photoId: editingPoem.photoId, uploadAt: editingPoem.uploadAt, isPrivate: isPrivate, likers: editingPoem.likers, photoURL: editingPoem.photoURL, userUID: currentAuth.userUID, isTemp: editingPoem.isTemp, isBlocked: false)
            case .temp(let writingPoem):
                return Poem(id: writingPoem.id, userEmail: currentAuth.userEmail, userNickname: currentAuth.userPenname, title: title, content: content, photoId: writingPoem.photoId, uploadAt: Date(), isPrivate: isPrivate, likers: [:], photoURL: writingPoem.photoURL, userUID: currentAuth.userUID, isTemp: writingPoem.isTemp, isBlocked: false)
            }
        }
        
        self.input = Input(title: title, content: content, isPrivate: isPrivate)
        self.output = Output(aPoem: aPoem)
    }
    
    func fetchAlertForInvalidPoem(poem: Poem) -> UIAlertController? {
        
        if let badwordAlert = self.fetchBadwordAlert(poem: poem) {
            return badwordAlert
        }else if poem.title.isEmpty && poem.content.isEmpty {
            return fetchBlankAlert()
        } else {
            return nil
        }
    }
    
    func fetchBadwordAlert(poem: Poem) -> UIAlertController?{
        
        if checkBadWords(content: poem.title + poem.content) {
            let alert = UIAlertController(title: "이상 내용 감지", message: "창작의 자유를 존중하지만\n정책상 비속어 게시가 불가합니다", preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: .default)
            alert.addAction(action)
            return alert
        } else {
            return nil
        }
    }
    
    func fetchBlankAlert() -> UIAlertController{
        let alert = UIAlertController(title: "이상 내용 감지", message: "공백의 글은 게시할 수 없습니다", preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default)
        alert.addAction(action)
        return alert
    }
    
}

enum WritingType {
    
    case write(WeekPhoto)
    case edit(Poem)
    case temp(Poem)
    
}

enum AlertType {
    
    case badWords
    case blank
    
}
