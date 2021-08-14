//
//  UserRegisterViewController.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/14.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import FirebaseAuth
import GoogleSignIn
import Firebase

class UserRegisterViewController: UIViewController, ViewModelBindable, StoryboardBased, HasDisposeBag {
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    
    var viewModel: UserRegisterViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signInButton.addTarget(self, action: #selector(googleLogin), for: .touchUpInside)
        
    }
    
    func bindViewModel() {
        
    }
    
    @objc func googleLogin(){
        guard let clientId = FirebaseApp.app()?.options.clientID else {return}
        
        let config = GIDConfiguration(clientID: clientId)
        print(config.clientID)
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in

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

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print(error.localizedDescription)
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
}


