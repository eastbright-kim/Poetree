//
//  MainViewModel.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/10.
//

import Foundation
import RxSwift
import RxCocoa
import NSObject_Rx


class MainViewModel: ViewModelType {
    
    let poemService: PoemService
    let disposebag = DisposeBag()
    
    struct Input {
        
    }
    
    struct Output {
        let currentDate: Driver<String>
        let thisWeekPhotoURL: Observable<[WeekPhoto]>
    }
    
    var input: Input
    var output: Output
    
    init(poemService: PoemService){
        
        self.poemService = poemService
        
        let currentDate = Observable<String>.just(poemService.getCurrentDate())
            .asDriver(onErrorJustReturn: "Jan 1st")
        
        let thisWeekPhotoURL = poemService.thisWeekPhotos()
            
        poemService.getWeekPhotos { weekPhotos in
            print(weekPhotos)
        }
        
        self.input = Input()
        self.output = Output(currentDate: currentDate, thisWeekPhotoURL: thisWeekPhotoURL)
    }
}
