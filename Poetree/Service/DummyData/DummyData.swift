//
//  DummyData.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/11.
//

import UIKit

//var poems = [Poem(title: "123", content: "456", poemId: 1, sourceId: 1, uploadAt: Date(), imageURL: UIImage(named: "image1.jpg")!, likes: users.count, isPublic: true, likers: users),
//    Poem(title: "456", content: "789", poemId: 2, sourceId: 2, uploadAt: Date.yesterday, imageURL: UIImage(named: "image2.jpg")!, likes: users.count, isPublic: true, likers: users),
//    Poem(title: "101112", content: "11124124.jpg", poemId: 3, sourceId: 3, uploadAt: Date.distantPast, imageURL: UIImage(named: "image3")!, likes: users.count, isPublic: false, likers: users)]

let users = [User(email: "1.2@com", nickName: "kim", userId: "1"),
             User(email: "3.4@com", nickName: "lee", userId: "2"),
             User(email: "5.6@com", nickName: "park", userId: "3"),
             User(email: "7.8@com", nickName: "choi", userId: "4"),
             User(email: "9.10@com", nickName: "hong", userId: "5")]

var whites = [URL(string: "https://firebasestorage.googleapis.com/v0/b/poetree-e472e.appspot.com/o/white%2F2-2.jpg?alt=media&token=3945142a-4a01-431b-9a0c-51ff8ee10538")!, URL(string: "https://firebasestorage.googleapis.com/v0/b/poetree-e472e.appspot.com/o/white%2F2-2.jpg?alt=media&token=3945142a-4a01-431b-9a0c-51ff8ee10538")!, URL(string: "https://firebasestorage.googleapis.com/v0/b/poetree-e472e.appspot.com/o/white%2F2-2.jpg?alt=media&token=3945142a-4a01-431b-9a0c-51ff8ee10538")!]
