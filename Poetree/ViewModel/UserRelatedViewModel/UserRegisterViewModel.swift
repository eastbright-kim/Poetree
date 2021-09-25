//
//  UserRegisterViewModel.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/14.
//

import Foundation
import RxSwift
import RxCocoa

class UserRegisterViewModel: ViewModelType {
    
    let userService: UserService!
    
    
    struct Input {
        let pennameInput: BehaviorSubject<String>
    }
    
    struct Output {
        let isCompleteBtnValid: Driver<Bool>
        let validLetter: Driver<String>
    }
    
    
    var input: Input
    var output: Output
    
    
    init(userService: UserService){
        
        self.userService = userService
        
        let pennameInput = BehaviorSubject<String>(value: "")
        
        let isCompleteBtnValid = pennameInput
            .map { letter in
                if (letter.count == 0 || letter.contains(" ")) || checkBadWords(content: letter){
                    return false
                }
                return true
            }
            .asDriver(onErrorJustReturn: false)
        
        let validLetter = pennameInput
            .map { letter -> String in
                if letter.contains(" ") {
                    return "필명엔 공백이 포함될 수 없습니다."
                } else if letter.count == 0 {
                    return "필명엔 공백이 포함될 수 없습니다."
                } else if checkBadWords(content: letter) {
                    return "필명엔 욕설이 포함될 수 없습니다."
                }else {
                    return ""
                }
            }
            .asDriver(onErrorJustReturn: "필명은 로그인 후 수정할 수 없으니\n신중히 선택해주세요 :)")
            
        
        self.input = Input(pennameInput: pennameInput)
        self.output = Output(isCompleteBtnValid: isCompleteBtnValid, validLetter: validLetter)
    }
}
