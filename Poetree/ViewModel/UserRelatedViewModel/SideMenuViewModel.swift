//
//  SideMenuViewModel.swift
//  Poetree
//
//  Created by κΉλν on 2021/09/12.
//

import Foundation

class SideMenuViewModel {
    
    let userService: UserService
    let poemServcie: PoemService
    
    init(poemService: PoemService, userService: UserService) {
        self.userService = userService
        self.poemServcie = poemService
    }
    
}
