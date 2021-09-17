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
        let poem = poemService.allPoems()
        
        let currentUser = user.asDriver(onErrorJustReturn: CurrentAuth(userEmail: "unknowned", userPenname: "unknowned", userUID: "unknowned"))
        
        let userWritings = Observable.combineLatest(user, poem){
            user, poem -> [Poem] in
            
            let userWritings = poemService.fetchUserWriting(poem: poem, currentUser: user)
            
            if userWritings.count == 0 {

                let defaultPoem = Poem(id: "", userEmail: "", userNickname: "", title: "no writings yet", content: "", photoId: 0, uploadAt: Date(), isPrivate: false, likers: [:], photoURL: URL(string: "https://i.ibb.co/6yQ5kzm/image6.jpg")!, userUID: "", isTemp: false)
                return [defaultPoem]
            }
            
            return userWritings
        }
        .map(poemService.sortPoemsByLikeCount_random)
        
        let userLikedWritings = Observable.combineLatest(user, poem){
            user, poem -> [Poem] in
            
            let userLikedWritings = poemService.fetchUserLikedWriting(poems: poem, currentUser: user).sorted { p1, p2 in
                p1.likers.count > p2.likers.count
            }
            
            return userLikedWritings
        }
        
        self.input = Input()
        self.output = Output(loginUser: currentUser, userWritings: userWritings, userLikedWritings: userLikedWritings)
    }
    
    func logout(){
        userService.logout()
    }
}
