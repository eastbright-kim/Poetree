//
//  FirebaseReference.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/16.
//

import Foundation
import Firebase


let poemRef = Database.database().reference().child("poem")
let photoRef = Database.database().reference().child("photos")
let currentUser = Auth.auth().currentUser
let userRef = Database.database().reference().child("users")
