//
//  UserService.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/22.
//

import Foundation
import GoogleSignIn
import FBSDKLoginKit
import Firebase
import RxSwift

class UserService {
    
    let userRegisterRepository: UserRegisterRepository!
    private var defaultUser = CurrentUser(userEmail: currentUser?.email ?? "unknowned", userPenname: currentUser?.displayName ?? "unknowned", userUID: currentUser?.uid ?? "unknowned")
    private lazy var loginUser = BehaviorSubject<CurrentUser>(value: defaultUser)
    
    init(userRegisterRepository: UserRegisterRepository){
        self.userRegisterRepository = userRegisterRepository
    }
    
    func loggedInUser() -> Observable<CurrentUser> {
        return loginUser
    }
    
    
    func googleLogin(penname: String, presentingVC: UIViewController, completion: @escaping ((Bool) -> Void)){
        
        guard let clientId = FirebaseApp.app()?.options.clientID else {return}
        let config = GIDConfiguration(clientID: clientId)
        GIDSignIn.sharedInstance.signIn(with: config, presenting: presentingVC) { user, error in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,accessToken: authentication.accessToken)
            
            self.userRegisterRepository.RegisterToFirebase(penname: penname, flatform:FlatFormType.Google_Facebook(credential)) { result in
                switch result {
                case .success(let loggedInUser):
                    completion(true)
                    
                    self.loginUser.onNext(loggedInUser)
                case .failure(let error):
                    completion(false)
                    print(error)
                }
            }
        }
    }
    
    func facebookLogin(penname: String, presentingVC: UIViewController, completion: @escaping ((Bool) -> Void)){
        
        let loginManager = LoginManager()
        loginManager.logIn(permissions: [.email], viewController: presentingVC) { result in
            switch result {
            
            case .success(granted: _, declined: _, token: let token):
                
                let credential = FacebookAuthProvider
                    .credential(withAccessToken: token!.tokenString)
                self.userRegisterRepository.RegisterToFirebase(penname: penname, flatform: .Google_Facebook(credential)) { result in
                    
                    switch result {
                    case .success(let loggedInUser):
                        completion(true)
                        
                        self.loginUser.onNext(loggedInUser)
                    case .failure(let error):
                        completion(false)
                        print(error)
                    }
                }
            case .cancelled:
                print("facebooklogin cancelled")
                break
            case .failed:
                print("facebooklogin failed")
                break
            }
        }
    }
    
    func appleLogin(penname: String, credential: OAuthCredential, completion: @escaping ((Bool) -> Void)){
        self.userRegisterRepository.RegisterToFirebase(penname: penname, flatform: .Apple(credential)) { result in
            
            switch result {
            case .success(let loggedInUser):
                completion(true)
             
                self.loginUser.onNext(loggedInUser)
            case .failure(let error):
                completion(false)
                print(error)
            }
        }
    }
}
