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
    let poemSevice: PoemService
    let photoService: PhotoService
    let userService: UserService
    
    struct Input {
        let photoSelected: ReplaySubject<WeekPhoto>
    }
    
    struct Output {
       
        let displayingPhoto: Observable<[WeekPhoto]>
        let lastWeekPhotos: Observable<[WeekPhoto]>
        let displyingPoemsByPhoto: Observable<[Poem]>
    }
    
    var input: Input
    var output: Output
    
    init(poemSevice: PoemService, photoService: PhotoService,  userService: UserService) {
        
        
        let allPhotos = photoService.photos()
            
        let allPoems = poemSevice.allPoems()
                .map(poemSevice.filterPoemsForPublic)
        
        let displayingPhoto = allPhotos.map(photoService.photoReveredOrder)
        
        let lastWeekPhotos = allPhotos.map{ photos in Array(photoService.fetchLastWeekPhotos(weekPhotos: photos).prefix(3)) }
        
        let photoSelected = ReplaySubject<WeekPhoto>.create(bufferSize: 1)
        
        lastWeekPhotos.map(photoService.getInitialPhoto)
            .subscribe(onNext:{ first in
                guard let f = first else {return}
                photoSelected.onNext(f)
            })
            .disposed(by: disposeBag)
        
        let displyingPoemsByPhoto = Observable.combineLatest(allPoems, photoSelected) {
            poems, weekphoto -> [Poem] in
            let dpPoems = poemSevice.fetchPoemsByPhotoId_SortedLikesCount(poems: poems, photoId: weekphoto.id)
                .prefix(3)
            return Array(dpPoems)
        }
        
        
        self.input = Input(photoSelected: photoSelected)
        self.output = Output(displayingPhoto: displayingPhoto, lastWeekPhotos: lastWeekPhotos,displyingPoemsByPhoto: displyingPoemsByPhoto)
        self.poemSevice = poemSevice
        self.photoService = photoService
        self.userService = userService
    }
}
