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



class UserRegisterViewController: UIViewController, ViewModelBindable, StoryboardBased {
    
    
    var viewModel: UserRegisterViewModel!
    @IBOutlet weak var logoImage: UIImageView!
    
    
    // ------------------------------ AVPlayer
    
    @IBOutlet weak var videoLayer: UIView!
    var avPlayerLooper: AVPlayerLooper!
    var avQueuePlayer: AVQueuePlayer!
    let asset = AVAsset(url: URL(fileURLWithPath: Bundle.main.path(forResource: "shadow", ofType: "mp4")!))
    
    
    // ------------------------------ PenNameSettingView
    @IBOutlet weak var penNameTextField: UITextField!
    var penName: String?
    @IBOutlet weak var penNameStackView: UIStackView!
    
    
    // ------------------------------ regiserView
    
    @IBOutlet weak var registerStackView: UIStackView!
    @IBOutlet weak var googleLogInBtn: UIButton!
    @IBOutlet weak var appleLogInBtn: UIButton!
    @IBOutlet weak var facebookLogInBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playVideo()
        setupAppleBtn()
    }
    
    
    func setupAppleBtn(){
        appleLogInBtn.addTarget(self, action: #selector(performAppleSignIn), for: .touchUpInside)
    }
    
    func bindViewModel() {
        
        googleLogInBtn.rx.tap
            .subscribe { [unowned self] _ in
                self.viewModel.userService.googleLogin(penname: self.penName!, presentingVC: self) { result in
                    switch result {
                    case true:
                        print("구글성공")
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                        }
                    case false:
                        print("구글안됨")
                    }
                }
            }
            .disposed(by: rx.disposeBag)
        
        
        facebookLogInBtn.rx.tap
            .subscribe(onNext:{[unowned self] _ in
                self.viewModel.userService.facebookLogin(penname: penName!, presentingVC: self) { result in
                    switch result {
                    case true:
                        print("페북성공")
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                        }
                    case false:
                        print("페북안됨")
                    }
                }
            })
            .disposed(by: rx.disposeBag)
        
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




//MARK: ----------------------AppleLogin

extension UserRegisterViewController {
    
    @objc func performAppleSignIn(){
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

            self.viewModel.userService.appleLogin(penname: penName!, credential: credential) { result in
                
                switch result{
                case true:
                    print("애플 등록")
                    self.dismiss(animated: true, completion: nil)
                case false:
                    print("애플 안됨")
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
