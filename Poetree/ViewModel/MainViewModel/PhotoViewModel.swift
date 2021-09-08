//
//  PhotoViewModel.swift
//  Poetree
//
//  Created by 김동환 on 2021/09/07.
//

import Foundation
import RxSwift
import RxCocoa

class PhotoViewModel: ViewModelType {
    
    let userService: UserService
    let poemService: PoemService
    let photoService: PhotoService
    
    var input: Input
    var output: Output
    
    struct Input {
     
    }
    
    struct Output {
        
        let thisWeekPhoto: Observable<[WeekPhoto]>
        
    }
    
    init(userService: UserService, poemService: PoemService, photoService: PhotoService){
        
        self.userService = userService
        self.poemService = poemService
        self.photoService = photoService
        
        let photos = photoService.photos()
        
        let thisWeekPhoto = photos.map(photoService.getThisWeekPhoto)
        
        
        self.input = Input()
        self.output = Output(thisWeekPhoto: thisWeekPhoto)
    }
}
