//
//  SceneDelegate.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/09.
//

import UIKit
import FBSDKCoreKit
import RxSwift
import RxCocoa

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)

        let poemRepository = PoemRepository()
        let photoRepository = PhotoRepository()
        let userRegisterRepository = UserRegisterRepository()
        let photoServie = PhotoService(photoRepository: photoRepository)
        let poemService = PoemService(poemRepository: poemRepository)
        let userService = UserService(userRegisterRepository: userRegisterRepository)

        poemRepository.fetchPoems { poemEntities, result in
            
            let poemModels = poemEntities.map { poemEntity -> Poem in
                let id = poemEntity.id
                let userEmail = poemEntity.userEmail
                let userNickname = poemEntity.userNickname
                let title = poemEntity.title
                let content = poemEntity.content
                let photoId = poemEntity.photoId
                let uploadAt = convertStringToDate(dateFormat: "yyyy MMM d", dateString: poemEntity.uploadAt)
                let isPublic = poemEntity.isPublic
                let likers = poemEntity.likers
                let photoURL = URL(string: poemEntity.photoURL)!
                let userUID = currentUser.uid
               
                return Poem(id: id, userEmail: userEmail, userNickname: userNickname, title: title, content: content, photoId: photoId, uploadAt: uploadAt, isPrivate: isPublic, likers: likers, photoURL: photoURL, userUID: userUID)
            }

            poemService.poems = poemModels
            poemService.poemsStore.onNext(poemModels)
        }
        
        photoRepository.fetchPhotos { photoEntities in
            let weekPhotos = photoEntities.map { entity -> WeekPhoto in
                let url = URL(string: entity.imageURL)!
                let photoId = entity.photoId
                let date = convertStringToDate(dateFormat: "yyyy MMM d", dateString: entity.date)
                return WeekPhoto(date: date, id: photoId, url: url)
            }.sorted { p1, p2 in
                p1.date.timeIntervalSinceReferenceDate > p1.date.timeIntervalSinceReferenceDate
            }.filter { weekPhoto in
                let thisMonday = getMonday(myDate: Date())
                return weekPhoto.date.timeIntervalSinceReferenceDate <= thisMonday.timeIntervalSinceReferenceDate
            }
            
            photoServie.weekPhotos = weekPhotos
            photoServie.photoStore.onNext(weekPhotos)
        }
        
    
        var mainVC = MainViewController.instantiate(storyboardID: "Main")
        mainVC.bind(viewModel: MainViewModel(poemService: poemService, photoService: photoServie))
        let mainNVC = UINavigationController(rootViewController: mainVC)
        mainNVC.navigationController?.navigationBar.prefersLargeTitles = true

        var historyVC = HistoryViewController.instantiate(storyboardID: "Main")
        historyVC.bind(viewModel: HistoryViewModel(poemSevice: poemService, photoService: photoServie))
        let historyNVC = UINavigationController(rootViewController: historyVC)


        var userPoemVC = UserPageViewController.instantiate(storyboardID: "UserRelated")
        userPoemVC.bind(viewModel: MyPoemViewModel(poemService: poemService, userService: userService))
        let userNAV = UINavigationController(rootViewController: userPoemVC)


        let tabBarController = UITabBarController()
        tabBarController.setViewControllers([mainNVC, historyNVC, userNAV], animated: false)
        
        

        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }

        ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: url,
            sourceApplication: nil,
            annotation: [UIApplication.OpenURLOptionsKey.annotation]
        )
    }

}

