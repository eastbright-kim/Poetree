//
//  UserService.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/22.
//

import Foundation
import GoogleSignIn
import AuthenticationServices
import FBSDKLoginKit
import Firebase

class UserService {
    
    let userRepository: UserRepository!
    
    
    init(userRepository: UserRepository){
        self.userRepository = userRepository
    }
    
    func googleLogin(){
        
//        guard let clientId = FirebaseApp.app()?.options.clientID else {return}
//
//        let config = GIDConfiguration(clientID: clientId)
//        print(config.clientID)
//        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
//
//            if let error = error {
//                print(error.localizedDescription)
//                return
//            }
//
//            guard
//                let authentication = user?.authentication,
//                let idToken = authentication.idToken
//            else {
//                return
//            }
//
//            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
//                                                           accessToken: authentication.accessToken)
//
//    }
    
    }
}
