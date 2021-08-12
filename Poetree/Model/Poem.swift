//
//  Poem.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/10.
//

import UIKit

struct Poem: Equatable {
    
    var title: String
    var content: String
    let poemId: Int
    let sourceId: Int
    let uploadAt: Date
    let imageURL: URL
    var likes: Int = 0
    var isPublic: Bool = true
    var likers: [User]
    
    static func == (lhs: Poem, rhs: Poem) -> Bool {
        return true
    }
}

struct PoemByPhoto: Equatable {
    
    let id: Int
    let sourceId: Int
    let imageURL: URL
    var poems: [Poem]
    
    static func == (lhs: PoemByPhoto, rhs: PoemByPhoto) -> Bool {
        return true
    }
}



