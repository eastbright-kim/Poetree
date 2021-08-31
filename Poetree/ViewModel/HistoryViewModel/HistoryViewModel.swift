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
       
        let allPhotos: Observable<[WeekPhoto]>
        let lastWeekPhotos: Observable<[WeekPhoto]>
    }
    
    var input: Input
    var output: Output
    
    init(poemSevice: PoemService, photoService: PhotoService) {
        
        
        let allPhotos = photoService.photos()
        
        let lastWeekPhotos = allPhotos.map(photoService.fetchLastWeekPhotos)
        
        self.input = Input()
        self.output = Output(allPhotos: allPhotos, lastWeekPhotos: lastWeekPhotos)
        self.poemSevice = poemSevice
        self.photoService = photoService
    }
}
