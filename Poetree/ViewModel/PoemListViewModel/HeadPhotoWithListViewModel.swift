//
//  HeadPhotoWithListViewModel.swift
//  Poetree
//
//  Created by 김동환 on 2021/09/09.
//

import Foundation
import RxSwift
import RxCocoa

class HeadPhotoWithListViewModel: ViewModelType {
    
    var input: Input
    var output: Output
    
    let poemService: PoemService
    let userService: UserService
    
    struct Input{
        
    }
    
    struct Output {
        var displayingPoem: Observable<[Poem]>
        var weekPhoto: WeekPhoto?
        
    }
    
    init(poemService: PoemService, userService: UserService, weekPhoto: WeekPhoto? = nil, displayingPoems: Observable<[Poem]>){
        
       
        self.poemService = poemService
        self.userService = userService
        
        displayingPoems
            .subscribe(onNext:{ poem in
                print(poem.count)
            })
            
     
        self.input = Input()
        self.output = Output(displayingPoem: displayingPoems, weekPhoto: weekPhoto)
    }
}

enum ListType {
    
    case fromDisplayingPoem(Observable<[Poem]>)
    case weekPhoto(WeekPhoto)
    
}
