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
import AuthenticationServices

class UserRegisterViewController: UIViewController, ViewModelBindable, StoryboardBased, HasDisposeBag {
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    
    var viewModel: UserRegisterViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInButton.addTarget(self, action: #selector(googleLogin), for: .touchUpInside)
        setupSignInButton()
    }
    
    
    func setupSignInButton(){
        
        let button = ASAuthorizationAppleIDButton()
        button.addTarget(self, action: #selector(handleSignInWithAppleTapped), for: .touchUpInside)
        button.center = view.center
        view.addSubview(button)
    }
    
    @objc func handleSignInWithAppleTapped(){
        performAppleSignIn()
    }
    
    func performAppleSignIn(){
        let request = createAppleIDRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        
        authorizationController.performRequests()
    }
    
    func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.email, .fullName]
        
        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        currentNonce = nonce
        return request
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


private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
            }
            return random
        }
        
        randoms.forEach { random in
            if remainingLength == 0 {
                return
            }
            
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }
    
    return result
}



extension UserRegisterViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("no login request was sent")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {print("unable to fetch id token")
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {print("idTokenString error")
                return}
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            Auth.auth().signIn(with: credential) { authDataResult, error in
                if let user = authDataResult?.user {
                    print(user.displayName)
                    self.dismiss(animated: true, completion: nil)
                }
                
            }
        }
    }
}

extension UserRegisterViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

import CryptoKit

// Unhashed nonce.
fileprivate var currentNonce: String?

@available(iOS 13, *)

@available(iOS 13, *)
private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
    }.joined()
    
    return hashString
}
