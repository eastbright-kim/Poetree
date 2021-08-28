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
        let selectedPhotoId: BehaviorSubject<Int>
    }
    
    struct Output {
        let currentDate: Driver<String>
        let thisWeekPhotoURL: Observable<[WeekPhoto]>
        let displayingPoems: Observable<[Poem]>
    }
    
    var input: Input
    var output: Output
    
    init(poemService: PoemService, photoService: PhotoService){
        
        
        self.poemService = poemService
        self.photoService = photoService
        
        let currentDate = Observable<String>.just(poemService.getCurrentDate())
            .asDriver(onErrorJustReturn: "Jan 1st")
        let thisWeekPhotoURL = photoService.thisWeekPhotos()
        
        
        
        let selectedPhotoId = BehaviorSubject<Int>(value: 0)
        
        let displayingPoems = Observable.combineLatest(poemService.allPoems(), selectedPhotoId){ poems, photoId -> [Poem] in
            let disPlayingPoem = poems.filter { poem in
                poem.photoId == photoId
            }
            return disPlayingPoem
        }
            
        
        self.input = Input(selectedPhotoId: selectedPhotoId)
        self.output = Output(currentDate: currentDate, thisWeekPhotoURL: thisWeekPhotoURL, displayingPoems: displayingPoems)

    }
}
