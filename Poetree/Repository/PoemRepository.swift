//
//  PoemRepository.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/11.
//

import Foundation
import Firebase
import Kingfisher

class PoemRepository {
    
    let ref = Storage.storage().reference().child("images")
    
    func getWeekPhoto(completion: @escaping ([WeekPhoto]) -> Void) {
        
        var photo = [WeekPhoto]()
        
        self.ref.listAll { result, error in
            guard error == nil else { print("storage list error")
                return }
            for item in result.items {
                let name = item.name.components(separatedBy: ".")[0]
                item.downloadURL { url, error in
                    guard error == nil else { print( "url error")
                        return}
                    if let url = url {
                        KingfisherManager.shared.retrieveImage(with: url) { result in
                            switch result {
                            case .success(let image):
                                photo.append(WeekPhoto(id: Int(name)!, url: url, image: image.image))
                                if photo.count == 3 {
                                    completion(photo)
                                }
                            case .failure(let e):
                                //사진 못불러왔을때.
                                print(e)
                                photo = whites
                            }
                            
                        }
                    }
                }
            }
        }
    }
}
