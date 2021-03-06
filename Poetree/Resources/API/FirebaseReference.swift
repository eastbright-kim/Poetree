//
//  FirebaseReference.swift
//  Poetree
//
//  Created by κΉλν on 2021/08/16.
//

import Foundation
import Firebase


let poemRef = Database.database().reference().child("poem")
let photoRef = Database.database().reference().child("photos")
let reportedPoemRef = Database.database().reference().child("reportedPoem")
let noticeRef = Database.database().reference().child("notices")
let blockingRef = Database.database().reference().child("blocking")
