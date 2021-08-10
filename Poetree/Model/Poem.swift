//
//  Poem.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/10.
//

import Foundation

struct Poem: Equatable {
    
    var title: String
    var content: String
    let poemId: Int
    let email: String
    let sourceId: Int
    let uploadAt: Date
    var nickName: String
    let imageURL: URL
    var likes: Int = 0
    var isPublic: Bool = true
    var likers: [UserInfo]
    
    static func == (lhs: Poem, rhs: Poem) -> Bool {
        return true
    }
    
}

struct PoemByPhoto: Equatable {
    
    let id: Int
    var title: String
    var content: String
    let createdAt: Date
    let email: String
    let sourceId: Int
    var nickName: String
    var likes: Int = 0
    let imageURL: URL
    
    static func == (lhs: PoemByPhoto, rhs: PoemByPhoto) -> Bool {
        return true
    }
    
}
