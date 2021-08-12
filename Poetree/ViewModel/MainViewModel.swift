//
//  MainViewModel.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/10.
//

import Foundation
import RxSwift
import RxCocoa
import Action
import NSObject_Rx


class MainViewModel: ViewModelType {
    
    let poemService: PoemService
    let disposebag = DisposeBag()
    
    struct Input {
        
    }
    
    struct Output {
        let currentDate: Driver<String>
        let thisWeekPhotoURL: Observable<[URL]>
    }
    
    var input: Input
    var output: Output
    
    init(poemService: PoemService){
        
        self.poemService = poemService
        
        let currentDate = Observable<String>.just(poemService.getCurrentDate())
            .asDriver(onErrorJustReturn: "Jan 1st")
        
        let thisWeekPhotoURL = poemService.photos()
            
        
        poemService.getWeekPhotoURLs { url in
            print("\(url)뷰모델")
        }
        
        self.input = Input()
        self.output = Output(currentDate: currentDate, thisWeekPhotoURL: thisWeekPhotoURL)
    }
}
