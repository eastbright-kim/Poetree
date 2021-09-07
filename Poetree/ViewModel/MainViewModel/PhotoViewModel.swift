//
//  PhotoViewModel.swift
//  Poetree
//
//  Created by 김동환 on 2021/09/07.
//

import Foundation

class PhotoViewModel: ViewModelType {
    
    let userService: UserService
    let poemService: PoemService
    let photoService: PhotoService
    
    var input: Input
    var output: Output
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    init(userService: UserService, poemService: PoemService, photoService: PhotoService){
        
        self.userService = userService
        self.poemService = poemService
        self.photoService = photoService
        
        
        
        self.input = Input()
        self.output = Output()
    }
    
    
}
