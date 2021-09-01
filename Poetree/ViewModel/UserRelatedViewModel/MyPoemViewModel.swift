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
        let loginUser: Driver<CurrentUser>
        let userWritings: Observable<[Poem]>
        let userLikedWritings: Observable<[Poem]>
    }
    
    var input: Input
    var output: Output
    
    init(poemService: PoemService, userService: UserService) {
        
        self.poemService = poemService
        self.userService = userService
        
        let user = userService.loggedInUser()
        let poem = poemService.allPoems()
        
        let currentUser = user.asDriver(onErrorJustReturn: CurrentUser(userEmail: "unknowned", userPenname: "unknowned", userUID: "unknowned"))
        
        let userWritings = Observable.combineLatest(user, poem){
            user, poem -> [Poem] in
            
            let userWritings = poemService.fetchUserWriting(poem: poem, currentUser: user)
            
            return userWritings
        }
        
        let userLikedWritings = Observable.combineLatest(user, poem){
            user, poem -> [Poem] in
            
            let userLikedWritings = poemService.fetchUserLikedWriting(poems: poem, currentUser: user)
            
            return userLikedWritings
        }
        
        
        self.input = Input()
        self.output = Output(loginUser: currentUser, userWritings: userWritings, userLikedWritings: userLikedWritings)
    }
}
