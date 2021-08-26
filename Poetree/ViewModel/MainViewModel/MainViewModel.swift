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
        let selectedPoem: BehaviorSubject<[Poem]>
        
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
        
        
        let photoId = self.photoService.fetchPhotoId(0)
        let initialPoems = self.poemService.fetchPoemForPhotoId(photoId: photoId)
        print(initialPoems.count)
        let selectedPoem = BehaviorSubject<[Poem]>(value: initialPoems)
        
        
        
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
