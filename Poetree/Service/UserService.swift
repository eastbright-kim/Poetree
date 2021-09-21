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
    var currentUser = Auth.auth().currentUser
    var notices = [Notice]()
    
    private lazy var defaultUser = CurrentAuth(userEmail: currentUser?.email ?? "unknowned", userPenname: currentUser?.displayName ?? "unknowned", userUID: currentUser?.uid ?? "unknowned")
    
    private lazy var loginUser = BehaviorSubject<CurrentAuth>(value: defaultUser)
    
    init(userRegisterRepository: UserRegisterRepository){
        self.userRegisterRepository = userRegisterRepository
    }
    
    func loggedInUser() -> Observable<CurrentAuth> {
        return loginUser
    }
    
    
    func googleRegister(penname: String?, presentingVC: UIViewController, completion: @escaping ((Result<CurrentAuth, SignInErorr>) -> Void)){
        
        guard let clientId = FirebaseApp.app()?.options.clientID else {return}
        let config = GIDConfiguration(clientID: clientId)
        GIDSignIn.sharedInstance.signIn(with: config, presenting: presentingVC) { user, error in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let authentication = user?.authentication,
                  let idToken = authentication.idToken else { return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,accessToken: authentication.accessToken)
            
            
            guard let penname = penname else { self.userRegisterRepository.firebaseLogIn(credential: credential) { result in
                
                switch result {
                case .success(let currentAuth):
                    self.loginUser.onNext(currentAuth)
                    completion(.success(currentAuth))
                case .failure(let error):
                    completion(.failure(.LoginError(error)))
                }
            }
            return
            }
            
            self.register(penname: penname, credential: credential) { result in
   
                switch result {
                case .success(let currentUser):
                    completion(.success(currentUser))
                case .failure(let error):
                    completion(.failure(.RegisterError(error)))
                }
            }
        }
    }
    
    func facebookRegister(penname: String?, presentingVC: UIViewController, completion: @escaping ((Result<CurrentAuth, SignInErorr>) -> Void)){
        
        let loginManager = LoginManager()
        loginManager.logIn(permissions: [.email], viewController: presentingVC) { result in
            switch result {
            
            case .success(granted: _, declined: _, token: let token):
                
                let credential = FacebookAuthProvider
                    .credential(withAccessToken: token!.tokenString)
                
                guard let penname = penname else { self.userRegisterRepository.firebaseLogIn(credential: credential) { result in
             
                    switch result {
                    case .success(let currentAuth):
                        self.loginUser.onNext(currentAuth)
                        completion(.success(currentAuth))
                    case .failure(let error):
                        completion(.failure(.LoginError(error)))
                    }
                }
                return
                }
                self.register(penname: penname, credential: credential) { result in
       
                    switch result {
                    case .success(let currentUser):
                        completion(.success(currentUser))
                    case .failure(let error):
                        completion(.failure(.RegisterError(error)))
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
    
    func appleRegister(penname: String?, credential: OAuthCredential, completion: @escaping ((Result<CurrentAuth, SignInErorr>) -> Void)){
        
        guard let penname = penname else { self.userRegisterRepository.firebaseLogIn(credential: credential) { result in
     
            switch result {
            case .success(let currentAuth):
                self.loginUser.onNext(currentAuth)
                completion(.success(currentAuth))
            case .failure(let error):
                completion(.failure(.LoginError(error)))
            }
        }
        return
        }
        
        self.register(penname: penname, credential: credential) { result in

            switch result {
            case .success(let currentUser):
                completion(.success(currentUser))
            case .failure(let error):
                completion(.failure(.RegisterError(error)))
            }
        }
    }
    
    
    func register(penname: String, credential: AuthCredential, completion: @escaping ((Result<CurrentAuth, RegisterError>) -> Void)) {
        
        self.userRegisterRepository.RegisterToFirebase(penname: penname, credential: credential) { result in
            switch result {
            case .success(let loggedInUser):
                self.loginUser.onNext(loggedInUser)
                completion(.success(loggedInUser))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func logout(){
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            currentUser = nil
            loginUser.onNext(CurrentAuth(userEmail: "unknowned", userPenname: "비회원", userUID: ""))
            
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    func deleteUser() {
        
        let currentUser = Auth.auth().currentUser
        
        currentUser?.delete { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("user deleted")
            }
        }
    }
    
    func greetingLine(date: Date) -> String {
        
       let now = Calendar.current.component(.hour, from: date)
        
        switch now {
        case 21...24:
            return "편안한 밤 보내시길 바랍니다 🌙"
        case 0...5:
            return "편안한 밤 보내시길 바랍니다 🌙"
        case 6...11:
            return "좋은 아침입니다"
        case 12...17:
            return "좋은 하루 보내세요 :)"
        default:
            return "즐거운 저녁 시간 보내세요!"
        }
    }
}


enum SignInFlatform {
    
    case google
    case facebook
    
}

var sharedUUID = UUID().uuidString
