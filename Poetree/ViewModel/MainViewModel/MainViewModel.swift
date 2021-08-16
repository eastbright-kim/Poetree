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
    
    let photoService: PhotoService
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
    
    init(poemService: PoemService, photoService: PhotoService){
        
        self.poemService = poemService
        self.photoService = photoService
        
        let currentDate = Observable<String>.just(poemService.getCurrentDate())
            .asDriver(onErrorJustReturn: "Jan 1st")
        
        let thisWeekPhotoURL = photoService.thisWeekPhotos()
            
        photoService.getWeekPhotos { weekPhotos in
            print(weekPhotos)
        }
        
        self.input = Input()
        self.output = Output(currentDate: currentDate, thisWeekPhotoURL: thisWeekPhotoURL)
    }
}
