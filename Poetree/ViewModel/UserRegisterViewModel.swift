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
    
    let userService: UserService
    
    struct Input {
        let emailInput: PublishSubject<String>
        let penNameInput: BehaviorSubject<String>
        let passwordInput: PublishSubject<String>
    }
    
    struct Output {
        
        let checkEmailValid: Observable<Bool>
        let checkPasswordValid: Observable<Bool>
        let activateRegisterBtn: Observable<Bool>
        let newUser: Observable<User>
        
    }
    
    
    var input: Input
    var output: Output
    
    
    init(userService: UserService){
        
        let emailInput = PublishSubject<String>()
        let penNameInput = BehaviorSubject<String>(value: "")
        let passwordInput = PublishSubject<String>()
        
        let checkEmailValid = emailInput
            .map(userService.checkEmailValid(email:))
            
        let checkPasswordValid =
            passwordInput
            .map(userService.checkPasswordValid(password:))
            
        
        let newUser = Observable.combineLatest(emailInput.asObservable(), penNameInput.asObservable(), passwordInput.asObservable()) { email, penName, password in
            return User(email: email, password: password, penName: penName)
        }
        
        let activateRegisterBtn = Observable.combineLatest(checkEmailValid.asObservable(), checkPasswordValid.asObservable(), penNameInput.asObservable()) { (emailValid, passwordValid, penName) -> Bool in
            
            if emailValid && passwordValid && penName.count > 1 {
                print("ture래")
                return true
            } else {
                return false
            }
        }
            
        
        
        self.input = Input(emailInput: emailInput, penNameInput: penNameInput, passwordInput: passwordInput)
        
        self.output = Output(checkEmailValid: checkEmailValid, checkPasswordValid: checkPasswordValid, activateRegisterBtn: activateRegisterBtn, newUser: newUser)
        self.userService = userService
    }
    
}
