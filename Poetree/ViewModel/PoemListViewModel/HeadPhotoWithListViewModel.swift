//
//  HeadPhotoWithListViewModel.swift
//  Poetree
//
//  Created by 김동환 on 2021/09/09.
//

import Foundation
import RxSwift
import RxCocoa

class HeadPhotoWithListViewModel: ViewModelType {
    
    var input: Input
    var output: Output
    
    let poemService: PoemService
    let userService: UserService
    let photoService: PhotoService
    
    struct Input{
        
    }
    
    struct Output {
      
        let selectedPhoto: Observable<WeekPhoto>
        let displayingPoem: Observable<[Poem]>
    }
    
    init(poemService: PoemService, userService: UserService, photoService: PhotoService, selectedPhotoId: Int){
        
        self.poemService = poemService
        self.userService = userService
        self.photoService = photoService
     
        let poems = poemService.allPoems()
        let photos = photoService.photos()
        
        let displyingPoems = poems.map { poems in
            poemService.fetchPoemsByPhotoId(poems: poems, photoId: selectedPhotoId)
        }
        .map(poemService.sortPoemsByLikeCount_Random_Public)
        
        let selectedPhoto = photos.map { weekPhoto in
            photoService.fetchPhotoById(weekPhoto, id: selectedPhotoId)
        }
     
        self.input = Input()
        self.output = Output(selectedPhoto: selectedPhoto, displayingPoem: displyingPoems)
    }
}
