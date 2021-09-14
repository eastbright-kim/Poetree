//
//  UserRegisterPageViewController.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/21.
//

import UIKit

class UserRegisterPageViewController: UIPageViewController {
    
    var poemService: PoemService!
    var userService: UserService!
    
    var pages = [UIViewController]()
    let pagesControl = UIPageControl()
    let initialPage = 0
    
    init(poemService: PoemService, userService: UserService){
        self.poemService = poemService
        self.userService = userService
        
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpPages()
        setUpControl()
    }
    
    func setUpPages() {
        
        let viewModel = UserRegisterViewModel()
        
        var firstVC = FirstViewController.instantiate(storyboardID: "UserRelated")
        
        firstVC.bind(viewModel: viewModel)
        
        var secondVC = SecondViewController.instantiate(storyboardID: "UserRelated")
        
        secondVC.bind(viewModel: viewModel)
        
        self.pages.append(firstVC)
        self.pages.append(secondVC)
        
    }
    
    func setUpControl() {
        pagesControl.currentPageIndicatorTintColor = .systemYellow
        pagesControl.pageIndicatorTintColor = .gray
        pagesControl.numberOfPages = pages.count
        pagesControl.currentPage = initialPage
        
        view.addSubview(pagesControl)
        pagesControl.translatesAutoresizingMaskIntoConstraints = false
        pagesControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
        pagesControl.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        pagesControl.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
}

extension UserRegisterPageViewController: UIPageViewControllerDataSource {
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let index = self.pages.firstIndex(of: viewController) else {return nil}
        
        if index == 0 {
            return self.pages.last
        } else {
            return self.pages.first
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let index = self.pages.firstIndex(of: viewController) else {return nil}
        
        if index == self.pages.count - 1 {
            return self.pages.first
        } else {
            return self.pages.last
        }
    }
}

extension UserRegisterPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard let viewControllers = pageViewController.viewControllers else { return }
        guard let currentIndex = pages.firstIndex(of: viewControllers[0]) else { return }
        pagesControl.currentPage = currentIndex
        
    }
}
