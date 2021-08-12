//
//  Poem.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/10.
//

import UIKit

struct Poem: Equatable, Identifiable {
    
    var title: String
    var content: String
    let id: Int
    let photoId: Int
    let uploadAt: Date
    var isPublic: Bool = true
    var likers: [String]
    let userEmail: String
    var penName: String
    let photoURL: URL
    
    static func == (lhs: Poem, rhs: Poem) -> Bool {
        return true
    }
}

struct PhotoPoem: Equatable, Identifiable {
    
    var id: Int
    var photoId: Int
    var poems: [Poem]
    
}

struct WeekPhoto: Identifiable {
    let id: Int
    let url: URL
    let image: UIImage
}
