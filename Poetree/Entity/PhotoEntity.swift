//
//  PhotoEntity.swift
//  Poetree
//
//  Created by κΉλν on 2021/09/16.
//

import Foundation

struct PhotoEntity {
    let date: String
    let photoId: Int
    let imageURL: String
    
    init(photoDic: [String: Any]) {
        self.date = photoDic["date"] as? String ?? ""
        self.photoId = photoDic["id"] as? Int ?? 0
        self.imageURL = photoDic["url"] as? String ?? ""
    }
    
}
