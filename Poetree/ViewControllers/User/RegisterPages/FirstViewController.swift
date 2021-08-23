//
//  FirstViewController.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/21.
//

import UIKit
import AVFoundation
import Firebase
import AuthenticationServices
import RxSwift
import RxCocoa
import NSObject_Rx
import GoogleSignIn
import FBSDKLoginKit

class FirstViewController: UIViewController, ViewModelBindable, StoryboardBased {
    
    
    
    
    var viewModel: UserRegisterViewModel!
    
    // ------ AVPlayer
       
       @IBOutlet weak var videoLayer: UIView!
       var avPlayerLooper: AVPlayerLooper!
       var avQueuePlayer: AVQueuePlayer!
       let asset = AVAsset(url: URL(fileURLWithPath: Bundle.main.path(forResource: "ureru", ofType: "mp4")!))
    
    
    
    // ------ PenNameSettingView
    @IBOutlet weak var penNameSettingView: UIView!
    @IBOutlet weak var penNameTextField: UITextField!
    var penName: String?
    
    
    // ------ regiserView
    @IBOutlet weak var registerView: UIView!
    @IBOutlet weak var googleLoginBtn: GIDSignInButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playVideo()
        
        
        googleLoginSetup()
        appleLoginSetup()
        
        
        let loginButton = FBLoginButton()
        loginButton.center = view.center
        view.addSubview(loginButton)
        loginButton.delegate = self
        loginButton.permissions = ["public_profile", "email"]
        
    }
    
    
    
    func bindViewModel() {
        
    }
    
    
    func playVideo() {
        
        let item = AVPlayerItem(asset: asset)
        self.avQueuePlayer = AVQueuePlayer(playerItem: item)
        self.avPlayerLooper = AVPlayerLooper(player: self.avQueuePlayer, templateItem: item)
        
        let layer = AVPlayerLayer(player: self.avQueuePlayer)
        
        layer.frame = self.view.bounds
        layer.videoGravity = .resizeAspectFill
        self.videoLayer.layer.addSublayer(layer)
        
        avQueuePlayer.play()
        
        self.videoLayer.bringSubviewToFront(self.penNameSettingView)
    }
    
    
    @IBAction func btnTapped(_ sender: Any) {
        self.penName = penNameTextField.text
        self.videoLayer.sendSubviewToBack(self.penNameSettingView)
//        self.penNameSettingView.isHidden = true
        self.videoLayer.bringSubviewToFront(self.registerView)
    }
}






//MARK:- ----------------------GoogleLogin
extension FirstViewController {
    
    func googleLoginSetup(){
        
        googleLoginBtn.layer.cornerRadius = 13
        googleLoginBtn.addTarget(self, action: #selector(googleLogin), for: .touchUpInside)
        
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
            Auth.auth().signIn(with: credential) { authDataResult, error in
                //                if let user = authDataResult?.user {
                //                    print(user.displayName)
                //                    self.dismiss(animated: true, completion: nil)
                //                }
                
                Auth.auth().addStateDidChangeListener { (auth, user) in
                    guard let currentUser = auth.currentUser else { return }
                    let changeRequest = currentUser.createProfileChangeRequest()
                    changeRequest.displayName = self.penName
                    changeRequest.commitChanges { error in
                        if let error = error {
                            print("닉네임 등록 에러 : \(error.localizedDescription)")
                            //                            completion(false)
                        } else {
                            print("닉네임 정상 등록")
                            //                            completion(true)
                        }
                    }
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}


//MARK: ----------------------AppleLogin

extension FirstViewController {
    
    
    func appleLoginSetup(){
        let button = ASAuthorizationAppleIDButton()
        button.addTarget(self, action: #selector(handleSignInWithAppleTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false//막힌부분
        registerView.addSubview(button)//서브뷰먼저
        
        button.centerXAnchor.constraint(equalTo: self.registerView.centerXAnchor).isActive = true
        
        button.heightAnchor.constraint(equalTo: button.widthAnchor, multiplier: 1.0/6.0).isActive = true
        
        button.topAnchor.constraint(equalTo: self.googleLoginBtn.bottomAnchor, constant: 10).isActive = true
        
        button.trailingAnchor.constraint(equalTo: self.googleLoginBtn.trailingAnchor, constant: -3).isActive = true
        
        
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
    
}


extension FirstViewController: ASAuthorizationControllerDelegate {
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
                //                if let user = authDataResult?.user {
                //                    print(user.displayName)
                //                    self.dismiss(animated: true, completion: nil)
                //                }
                
                Auth.auth().addStateDidChangeListener { (auth, user) in
                    guard let currentUser = auth.currentUser else { return }
                    let changeRequest = currentUser.createProfileChangeRequest()
                    changeRequest.displayName = "tohji"
                    changeRequest.commitChanges { error in
                        if let error = error {
                            print("닉네임 등록 에러 : \(error.localizedDescription)")
                            //                            completion(false)
                        } else {
                            print("닉네임 정상 등록")
                            //                            completion(true)
                        }
                    }
                }
            }
        }
    }
}


extension FirstViewController: ASAuthorizationControllerPresentationContextProviding {
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


//MARK: ----------------------Facebook Login

extension FirstViewController: LoginButtonDelegate {
    
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        let credential = FacebookAuthProvider
            .credential(withAccessToken: AccessToken.current!.tokenString)
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            Auth.auth().addStateDidChangeListener { (auth, user) in
                guard let currentUser = auth.currentUser else { return }
                let changeRequest = currentUser.createProfileChangeRequest()
                changeRequest.displayName = self.penName
                changeRequest.commitChanges { error in
                    if let error = error {
                        print("닉네임 등록 에러 : \(error.localizedDescription)")
                        //                            completion(false)
                    } else {
                        print("닉네임 정상 등록")
                        //                            completion(true)
                    }
                }
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
    }
    
}
