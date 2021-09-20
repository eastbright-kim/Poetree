//
//  Protocol.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/10.
//

import UIKit
import RxSwift

protocol ViewModelBindable {
    associatedtype ViewModelType
    
    var viewModel: ViewModelType! { get set }
    
    func bindViewModel()
    
}

extension ViewModelBindable where Self: UIViewController {
    
    mutating func bind(viewModel: ViewModelType) {
        self.viewModel = viewModel
        loadViewIfNeeded()
        bindViewModel()
    }
}

protocol StoryboardBased {
    static func instantiate(storyboardID: String) -> Self
}

extension StoryboardBased where Self: UIViewController {
    static func instantiate(storyboardID: String) -> Self {
        let fullName = NSStringFromClass(self)
        let className = fullName.components(separatedBy: ".")[1]
        let sb = UIStoryboard(name: storyboardID, bundle: nil)
        return sb.instantiateViewController(identifier: className) as! Self
    }
}


protocol ViewModelType {
    
    associatedtype Input
    associatedtype Output
    
    var input: Input { get }
    var output: Output { get }
    
}


protocol UserLogInListener {
    func updatePenname(userResisterRepository: UserRegisterRepository, logInUser: CurrentAuth)
}
