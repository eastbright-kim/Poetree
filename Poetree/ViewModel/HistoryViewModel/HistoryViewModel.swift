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
//        let photoSelected: ReplaySubject<WeekPhoto>
        let indexSelected: BehaviorSubject<Int>
        
    }
    
    struct Output {
        let printedIndex: Driver<String>
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
        
        let indexSelected = BehaviorSubject<Int>(value: 0)
        
        let photoFromIndex = Observable.combineLatest(lastWeekPhotos, indexSelected){ weekPhotos, index -> WeekPhoto in
            
            if weekPhotos.count != 3 {
                return whites[index]
            }else {
                return weekPhotos[index]
            }
        }
        
        let printedIndex = indexSelected.map { num -> String in
            return "\(num + 1)"
        }.asDriver(onErrorJustReturn: "1")
        
        let displyingPoemsByPhoto = Observable.combineLatest(allPoems, photoFromIndex) {
            poems, weekphoto -> [Poem] in
            let dpPoems = poemSevice.fetchPoemsByPhotoId_SortedLikesCount(poems: poems, photoId: weekphoto.id)
                .prefix(3)
            return Array(dpPoems)
        }.map(poemSevice.filterBlockedPoem)
        
        self.input = Input(indexSelected: indexSelected)
        self.output = Output(printedIndex: printedIndex, displayingPhoto: displayingPhoto, lastWeekPhotos: lastWeekPhotos, displyingPoemsByPhoto: displyingPoemsByPhoto)
        self.poemSevice = poemSevice
        self.photoService = photoService
        self.userService = userService
    }
}
