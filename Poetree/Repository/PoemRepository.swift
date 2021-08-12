//
//  PoemRepository.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/11.
//

import Foundation
import Firebase

class PoemRepository {
    
    let ref = Storage.storage().reference().child("images")
    
    func getWeekPhoto(completion: @escaping ([URL]) -> Void) {
        
        var photoUrls = [URL]()
        
        self.ref.listAll { result, error in
            guard error == nil else { print("storage list error")
                return }
            for item in result.items {
                item.downloadURL { url, error in
                    guard error == nil else { print( "url error")
                        return}
                    if let url = url {
                        photoUrls.append(url)
                        if photoUrls.count == 3 {
                            completion(photoUrls)
                        }
                    }
                }
            }
        }
    }
}
