//
//  WritePoemViewModel.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/11.
//

import UIKit
import RxSwift
import RxCocoa

class WritePoemViewModel: ViewModelType {
    
    let weekPhoto: WeekPhoto
    let poemService: PoemService
    
    struct Input {
        
    }
    
    struct Output {
        let getCurrentDate: Driver<String>
    }
    
    var input: Input
    var output: Output
    
    init(weekPhoto: WeekPhoto, poemService: PoemService) {
        self.poemService = poemService
        self.weekPhoto = weekPhoto
        
        let getCurrentDate =  Observable<String>.just(poemService.getCurrentWritingTime())
            .asDriver(onErrorJustReturn: "좋은 날")
        
        self.input = Input()
        self.output = Output(getCurrentDate: getCurrentDate)
    }
}
