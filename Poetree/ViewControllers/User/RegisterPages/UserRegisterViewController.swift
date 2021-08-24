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

class UserRegisterViewController: UIViewController, ViewModelBindable, StoryboardBased {
    
    
    var viewModel: UserRegisterViewModel!
    @IBOutlet weak var logoImage: UIImageView!
    
    
    // ------ AVPlayer
    
    @IBOutlet weak var videoLayer: UIView!
    var avPlayerLooper: AVPlayerLooper!
    var avQueuePlayer: AVQueuePlayer!
    let asset = AVAsset(url: URL(fileURLWithPath: Bundle.main.path(forResource: "shadow", ofType: "mp4")!))
    
    // ------ PenNameSettingView
    @IBOutlet weak var penNameTextField: UITextField!
    var penName: String?
    @IBOutlet weak var penNameStackView: UIStackView!
    
    
    
    // ------ regiserView
    
    @IBOutlet weak var registerStackView: UIStackView!
    @IBOutlet weak var googleLogInBtn: UIButton!
    @IBOutlet weak var appleLogInBtn: UIButton!
    @IBOutlet weak var facebookLogInBtn: UIButton!
    
    
    //    @IBOutlet weak var facebookLogInBtn: FBLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playVideo()
        setupBtn()
    }
    
    
    func setupBtn(){
        
        facebookLoginSetup()
        googleLoginSetup()
        appleLoginSetup()
        
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
        
        self.videoLayer.bringSubviewToFront(self.logoImage)
        self.videoLayer.bringSubviewToFront(self.penNameStackView)
        self.videoLayer.sendSubviewToBack(self.registerStackView)
        self.penNameStackView.isHidden = false
    }
    
    
    @IBAction func btnTapped(_ sender: Any) {
        self.penName = penNameTextField.text
        self.videoLayer.sendSubviewToBack(self.penNameStackView)
        self.videoLayer.bringSubviewToFront(self.registerStackView)
        self.registerStackView.isHidden = false
    }
}


//MARK:- ----------------------GoogleLogin
extension UserRegisterViewController {
    
    func googleLoginSetup(){
        
        googleLogInBtn.addTarget(self, action: #selector(googleLogin), for: .touchUpInside)
        
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

extension UserRegisterViewController {
    
    
    func appleLoginSetup(){
        //        let button = ASAuthorizationAppleIDButton()
        appleLogInBtn.addTarget(self, action: #selector(handleSignInWithAppleTapped), for: .touchUpInside)
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
        request.requestedScopes = [.email]
        
        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        currentNonce = nonce
        return request
    }
    
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
            }
            self.dismiss(animated: true, completion: nil)
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

extension UserRegisterViewController {
    
    func facebookLoginSetup(){
        facebookLogInBtn.addTarget(self, action: #selector(facebookLogin), for: .touchUpInside)
    }
    
    
    @objc func facebookLogin(){
        
        
        let loginManager = LoginManager()
        loginManager.logIn(permissions: [.email], viewController: self) { result in
            switch result {
            
            case .success(granted: _, declined: _, token: let token):
                
                let credential = FacebookAuthProvider
                    .credential(withAccessToken: token!.tokenString)
                
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
            case .cancelled:
                break
                
            case .failed:
                break
            }
        }
    }
}
