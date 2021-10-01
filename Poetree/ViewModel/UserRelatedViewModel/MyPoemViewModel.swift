//
//  MyPoemViewModel.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/11.
//

import Foundation
import RxSwift
import RxCocoa

class MyPoemViewModel: ViewModelType {
    
    let poemService: PoemService!
    let userService: UserService!
    
    struct Input {
        
    }
    
    struct Output {
        let loginUser: Driver<CurrentAuth>
        let userWritings: Observable<[Poem]>
        let userLikedWritings: Observable<[Poem]>
    }
    
    var input: Input
    var output: Output
    
    init(poemService: PoemService, userService: UserService) {
        
        self.poemService = poemService
        self.userService = userService
        
        let user = userService.loggedInUser()
        let poem = poemService.allPoems().map(poemService.filterBlockedPoem)
        
        let currentUser = user.asDriver(onErrorJustReturn: CurrentAuth(userEmail: "unknowned", userPenname: "unknowned", userUID: "unknowned"))
        
        let userWritings = Observable.combineLatest(user, poem){
            user, poem -> [Poem] in
            let userWritings = poemService.fetchUserWriting(poem: poem, currentUser: user)
            if userWritings.count == 0 {
                let defaultPoem = Poem(id: "no writings yet", userEmail: "", userNickname: "", title: "no writings yet", content: "", photoId: 0, uploadAt: Date(), isPrivate: false, likers: [:], photoURL: URL(string: "https://i.ibb.co/6yQ5kzm/image6.jpg")!, userUID: "", isTemp: false, isBlocked: false)
                return [defaultPoem]
            }
            return userWritings
        }
        .subscribe(on: MainScheduler.instance)
        .map{poems -> [Poem] in
            let sorted = poemService.sortPoemsByLikeCount_Recent(poems).prefix(10)
            return Array(sorted)
        }
        
        let userLikedWritings = Observable.combineLatest(user, poem){
            user, poem -> [Poem] in
            let userLikedWritings = poemService.fetchUserLikedWriting_Sorted(poems: poem, currentUser: user).prefix(6)
            return Array(userLikedWritings)
        }
        
        self.input = Input()
        self.output = Output(loginUser: currentUser, userWritings: userWritings, userLikedWritings: userLikedWritings)
    }
    
    func logout(){
        userService.logout()
    }
}
