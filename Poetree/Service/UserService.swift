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

class UserService {
    
    let userRegisterRepository: UserRegisterRepository!
    
    
    init(userRegisterRepository: UserRegisterRepository){
        self.userRegisterRepository = userRegisterRepository
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
                case true:
                    completion(true)
                case false:
                    completion(false)
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
                    case true:
                        completion(true)
                    case false:
                        completion(false)
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
            
            switch result{
            case true:
                print("애플 등록")
                completion(true)
            case false:
                print("애플 안됨")
                completion(false)
            }
        }
    }
}
