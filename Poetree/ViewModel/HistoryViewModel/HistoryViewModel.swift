//
//  HistoryViewModel.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/11.
//

import Foundation
import RxSwift
import RxCocoa

class HistoryViewModel: ViewModelType {
    
    let poemSevice: PoemService!
    let photoService: PhotoService!
    
    struct Input {
        
    }
    
    struct Output {
        let lastWeekPoems: Observable<[Poem]>
        let allPhotos: Observable<[WeekPhoto]>
    }
    
    var input: Input
    var output: Output
    
    init(poemSevice: PoemService, photoService: PhotoService) {
        
        
        let lastWeekPoems = Observable.just(poemSevice.fetchLastWeekPoems())
        print(photoService.weekPhotos)
        let allPhotos = photoService.photos()
        
        self.input = Input()
        self.output = Output(lastWeekPoems: lastWeekPoems, allPhotos: allPhotos)
        self.poemSevice = poemSevice
        self.photoService = photoService
    }
}
