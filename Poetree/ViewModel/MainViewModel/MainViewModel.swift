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
    
    
    struct Input {
        let selectedPoem: PublishSubject<[Poem]>
        
    }
    
    struct Output {
        let currentDate: Driver<String>
        let thisWeekPhotoURL: Observable<[WeekPhoto]>
        let displayingPoems: Observable<[Poem]>
    }
    
    var input: Input
    var output: Output
    
    init(poemService: PoemService, photoService: PhotoService){
        
        photoService.getWeekPhotos { weekPhotos in
            
        }
        
        poemService.fetchPoems { poems, result in
            
        }
        
        
        self.poemService = poemService
        self.photoService = photoService
        
        let currentDate = Observable<String>.just(poemService.getCurrentDate())
            .asDriver(onErrorJustReturn: "Jan 1st")
        let thisWeekPhotoURL = photoService.thisWeekPhotos()
        
        let selectedPoem = PublishSubject<[Poem]>()
        
        let displayingPoems = selectedPoem
            .map { poems -> [Poem] in
                
                let displayingPoems = poems
                return displayingPoems
            }
            .asObservable()
       
        self.input = Input(selectedPoem: selectedPoem)
        self.output = Output(currentDate: currentDate, thisWeekPhotoURL: thisWeekPhotoURL, displayingPoems: displayingPoems)

    }
}
