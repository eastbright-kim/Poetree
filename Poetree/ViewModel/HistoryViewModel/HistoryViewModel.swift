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
    let disposeBag = DisposeBag()
    let poemSevice: PoemService!
    let photoService: PhotoService!
    
    struct Input {
        let photoSelected: ReplaySubject<WeekPhoto>
    }
    
    struct Output {
       
        let allPhotos: Observable<[WeekPhoto]>
        let lastWeekPhotos: Observable<[WeekPhoto]>
        let displayingPoems: Observable<[Poem]>
    }
    
    var input: Input
    var output: Output
    
    init(poemSevice: PoemService, photoService: PhotoService) {
        
        
        let allPhotos = photoService.photos()
        let allPoems = poemSevice.allPoems()
        
        let lastWeekPhotos = allPhotos.map(photoService.fetchLastWeekPhotos)
        let photoSelected = ReplaySubject<WeekPhoto>.create(bufferSize: 1)
        
        lastWeekPhotos.map(photoService.getInitialPhoto)
            .subscribe(onNext:{ first in
                guard let f = first else {return}
                photoSelected.onNext(f)
            })
            .disposed(by: disposeBag)
        
        
        let displayingPoems = Observable.combineLatest(allPoems, photoSelected){ poems, selectedPhoto -> [Poem] in
            
            let displaying = poems.filter { poem in
                poem.photoId == selectedPhoto.id
            }
            return displaying
        }
        .map(poemSevice.getThreeTopPoems)
        
        
        self.input = Input(photoSelected: photoSelected)
        self.output = Output(allPhotos: allPhotos, lastWeekPhotos: lastWeekPhotos, displayingPoems: displayingPoems)
        self.poemSevice = poemSevice
        self.photoService = photoService
    }
}
