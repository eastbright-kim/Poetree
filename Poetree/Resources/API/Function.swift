//
//  Function.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/12.
//

import Foundation
import UIKit


func convertDateToString(format: String, date: Date) -> String {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    let dateString = dateFormatter.string(from: date)
    return dateString
    
}

func convertStringToDate(dateFormat: String, dateString: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat
    let date = dateFormatter.date(from: dateString)!
    return date
}

func getWeekString(myDate: Date) -> String {
    if myDate.dayNumberOfWeek() == 1 {
        let weekNum = Calendar.current.component(.weekOfMonth, from: myDate)
        switch weekNum {
        case 1:
            return "1st"
        case 2:
            return "\(weekNum - 1)st"
        case 3:
            return "\(weekNum - 1)nd"
        case 4:
            return "\(weekNum - 1)rd"
        default:
            return "\(weekNum - 1)th"
        }
        
    } else {
        let weekNum = Calendar.current.component(.weekOfMonth, from: myDate)
        switch weekNum {
        case 1:
            return "\(weekNum)st"
        case 2:
            return "\(weekNum)nd"
        case 3:
            return "\(weekNum)rd"
        default:
            return "\(weekNum)th"
        }
    }
}


func getCycleString(time: Int) -> String {
    switch time {
    case 6..<12:
       return "아침"
    case 12..<18:
       return "낮"
    case 18..<21:
       return "저녁"
    default:
       return "밤"
    }
}

func getThisMonday(myDate: Date) -> Date {
    if myDate.dayNumberOfWeek() == 1 {
        let cal = Calendar.current
        var comps = cal.dateComponents([.weekOfYear, .yearForWeekOfYear], from: myDate)
        comps.weekday = 2
        let mondayInWeek = cal.date(from: comps)!
        let lastMonday = Calendar.current.date(byAdding: .day, value: -7, to: mondayInWeek)
        return lastMonday ?? mondayInWeek
    } else {
        let cal = Calendar.current
        var comps = cal.dateComponents([.weekOfYear, .yearForWeekOfYear], from: myDate)
        comps.weekday = 2
        let mondayInWeek = cal.date(from: comps)!
        return mondayInWeek
    }
}


struct BadWords: Codable {
    var badwords: [String]
}

func loadBadWordsFromJson() -> [String] {
    if let path = Bundle.main.path(forResource: "badwords", ofType: "json") {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            do {
                let badwordsModel = try JSONDecoder().decode(BadWords.self, from: data)
                return badwordsModel.badwords
            }
            catch {
                print("decode error")
                return []
            }
        }
        catch {
            print("path error")
            return []
        }
    } else {
        print("path nil")
        return []
    }
}

func checkBadWords(content: String) -> Bool {
    let badwords = loadBadWordsFromJson()
    for badword in badwords {
        if content.contains(badword) {
            return true
        }
    }
    return false
}

func makePhotoViewShadow(superView: UIView, photoImageView: UIImageView) {
    
    superView.clipsToBounds = false
    superView.layer.cornerRadius = 8
    superView.layer.shadowOffset = CGSize(width: 10,
                                          height: 10)
    superView.layer.shadowColor = UIColor.darkGray.cgColor
    superView.layer.shadowOpacity = 0.6
    superView.layer.shadowRadius = 10
    superView.layer.shadowPath = UIBezierPath(roundedRect: superView.bounds, cornerRadius: 8).cgPath
    photoImageView.clipsToBounds = true
    photoImageView.layer.cornerRadius = 8
    
}

func makePhotoViewShadowForWriting(superView: UIView, photoImageView: UIImageView) {
    
    superView.clipsToBounds = false
    superView.layer.cornerRadius = 8
    superView.layer.shadowOffset = CGSize(width: 10,
                                          height: 10)
    superView.layer.shadowColor = UIColor.gray.cgColor
    superView.layer.shadowOpacity = 0.6
    superView.layer.shadowRadius = 10
    superView.layer.shadowPath = UIBezierPath(roundedRect: superView.bounds, cornerRadius: 8).cgPath
    photoImageView.clipsToBounds = true
    photoImageView.layer.cornerRadius = 8
    
}

func makePhotoViewShadowForHistory(superView: UIView, photoImageView: UIImageView) {
    
    superView.clipsToBounds = false
    superView.layer.cornerRadius = 8
    superView.layer.shadowOffset = CGSize(width: 6,
                                          height: 5)
    superView.layer.shadowColor = UIColor.systemGray.cgColor
    superView.layer.shadowOpacity = 0.7
    superView.layer.shadowRadius = 6
    superView.layer.shadowPath = UIBezierPath(roundedRect: superView.bounds, cornerRadius: 8).cgPath
    photoImageView.clipsToBounds = true
    photoImageView.layer.cornerRadius = 8
    
}

import CryptoKit

// Unhashed nonce.
var currentNonce: String?

@available(iOS 13, *)

@available(iOS 13, *)
func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
    }.joined()
    
    return hashString
}



func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
            }
            return random
        }
        
        randoms.forEach { random in
            if remainingLength == 0 {
                return
            }
            
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }
    return result
}
