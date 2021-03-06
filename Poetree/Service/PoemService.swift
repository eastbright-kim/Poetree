//
//  PoemService.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/11.
//

import Foundation
import RxSwift
import Firebase

class PoemService: UserLogInListener {
    
    var poems = [Poem]()
    var blockedUserList = [String]()
    lazy var poemsStore = BehaviorSubject<[Poem]>(value: poems)
    
    let poemRepository: PoemRepository
    
    init(poemRepository: PoemRepository) {
        self.poemRepository = poemRepository
    }
    
    func allPoems() -> Observable<[Poem]> {
        return poemsStore
    }
    
    func createPoem(poem: Poem, completion: @escaping ((Result<Complete, Error>) -> Void)) {
        
        if poem.isTemp {
            poem.isTemp = false
            poemRepository.createPoem(poemModel: poem) { result in
                switch result {
                case .success(let success):
                    completion(.success(success))
                    guard let index = self.poems.firstIndex(of: poem) else { return }
                    self.poems[index] = poem
                    self.poemsStore.onNext(self.poems)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else{
            poemRepository.createPoem(poemModel: poem) { result in
                switch result {
                case .success(let success):
                    completion(.success(success))
                    self.poems.insert(poem, at: 0)
                    self.poemsStore.onNext(self.poems)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func fetchUserWritings(poem: [Poem], currentUser: CurrentAuth) -> [Poem] {
        
        let userWrting = poem.filter { poem in
            poem.userUID == currentUser.userUID
        }.filter{$0.isTemp == false}
        return userWrting
    }
    
    func fetchUserLikedWriting_Sorted(poems: [Poem], currentUser: CurrentAuth) -> [Poem] {
        //하나만 하게하기
        let userLikedPoems = poems.filter { poem in
            poem.likers[currentUser.userUID] ?? false
        }.sorted { p1, p2 in
            p1.likers.count > p2.likers.count
        }.filter { poem in
            if poem.userUID == currentUser.userUID {
                return true
            } else {
                return poem.isPrivate == false
            }
        }.filter { poem in
            poem.isTemp == false
        }
        return userLikedPoems
    }
    
    func editPoem(beforeEdited: Poem ,editedPoem: Poem, completion: @escaping((String) -> Void)){
        
        poemRepository.createPoem(poemModel: editedPoem) { result in
            switch result {
            case .success(let s):
         
                if let index = self.poems.firstIndex(of: beforeEdited) {
                    
                    self.poems[index] = editedPoem
                    self.poemsStore.onNext(self.poems)
                    completion(s.rawValue)
                }
                
            case .failure:
                completion("write poem error")
            }
        }
    }
    
    func deletePoem(deletingPoem: Poem) {
        poemRepository.deletePoem(poemModel: deletingPoem)
        guard let index = self.poems.firstIndex(where: {$0.id == deletingPoem.id}) else {return}
        poems.remove(at: index)
        self.poemsStore.onNext(self.poems)
    }
    
    func fetchPoemsByRefresh(completion: @escaping (Complete) -> Void) {
        
        poemRepository.fetchPoems { poemEntities in
            
            let poemModels = poemEntities.map { poemEntity -> Poem in
                let id = poemEntity.id
                let userEmail = poemEntity.userEmail
                let userNickname = poemEntity.userNickname
                let title = poemEntity.title
                let content = poemEntity.content
                let photoId = poemEntity.photoId
                let uploadAt = convertStringToDate(dateFormat: "yyyy MMM d", dateString: poemEntity.uploadAt)
                let isPrivate = poemEntity.isPrivate
                let likers = poemEntity.likers
                let photoURL = URL(string: poemEntity.photoURL) ?? URL(string: "https://firebasestorage.googleapis.com/v0/b/poetree-e472e.appspot.com/o/white%2F2-2.jpg?alt=media&token=3945142a-4a01-431b-9a0c-51ff8ee10538")!
                let userUID = poemEntity.userUID
                let isTemp = poemEntity.isTemp
                let reportedUsers = poemEntity.reportedUsers
                
                if let currentUser = Auth.auth().currentUser{
                    return Poem(id: id, userEmail: userEmail, userNickname: userNickname, title: title, content: content, photoId: photoId, uploadAt: uploadAt, isPrivate: isPrivate, likers: likers, photoURL: photoURL, userUID: userUID, isTemp: isTemp, isBlocked: reportedUsers[currentUser.uid] ?? false, currentUserUID: currentUser.uid)
                } else {
                    return Poem(id: id, userEmail: userEmail, userNickname: userNickname, title: title, content: content, photoId: photoId, uploadAt: uploadAt, isPrivate: isPrivate, likers: likers, photoURL: photoURL, userUID: userUID, isTemp: isTemp, isBlocked: false)
                }
            }.filter { poem in
                if let currentUser = Auth.auth().currentUser, poem.userUID == currentUser.uid {
                    return true
                } else {
                    if poem.isTemp == true || poem.isPrivate == true {
                        return false
                    } else {
                        return true
                    }
                }
            }
            
            self.poems = poemModels
            self.poemsStore.onNext(poemModels)
            completion(.fetchedPoem)
        }
    }
    
    func fetchPoemsByPhotoId_SortedLikesCount(poems: [Poem], photoId: Int) -> [Poem] {
        //하나만 하게하기
        let publicPoems = poems.filter{$0.isPrivate == false}
        
        let displayingPoems = publicPoems.filter { poem in
            return (poem.photoId == photoId)
        }.sorted { p1, p2 in
            p1.likers.count > p2.likers.count
        }
        
        return displayingPoems
    }
    
    func fetchPoemsByPhotoId(poems: [Poem], photoId: Int) -> [Poem] {
        let displayingPoems = poems.filter { poem in
            poem.photoId == photoId
        }
        return displayingPoems
    }
    
    func fetchThisWeekPoems(poems: [Poem]) -> [Poem] {
        let thisWeekPoems = poems.filter { poem in
            return poem.uploadAt >= getThisMonday(myDate: Date())
        }
        return thisWeekPoems
    }
    
    
    func getThreeTopPoems(_ poems: [Poem]) -> [Poem]{
        
        let sorted = poems.sorted{$0.likers.count > $1.likers.count}.prefix(3)
        
        return Array(sorted)
    }
    
    
    func getCurrentWeek() -> String {
        
        let currentDate = convertDateToString(format: "MMM-d", date: Date())
        let current = currentDate.components(separatedBy: "-")
        let week = getWeekString(myDate: Date())
        
        return "\(current[0]) " + week
    }
    
    func getWritingTimeString(date: Date) -> String {
        //한번에 하나
        let monthDay = convertDateToString(format: "M월 d일", date: date)
        let time = Int(convertDateToString(format: "H", date: date))!
        
        let cycle = getCycleString(time: time)
        
        let user = Auth.auth().currentUser?.displayName ?? "user"
        
        return "\(user)님이 \(monthDay) \(cycle)에 보내는 글"
    }
    
    func likeHandle(poem: Poem, user: User, completion: @escaping((Poem) -> Void)){
        //하나에 하나
        let poemIndex = self.poems.firstIndex(of: poem)
        
        guard let index = poemIndex else {return}
        
        if self.poems[index].isLike {
            self.poems[index].likers.removeValue(forKey: user.uid)
            self.poems[index].isLike = false
            completion(self.poems[index])
            self.poemsStore.onNext(self.poems)
            self.poemRepository.cancelLike(poem: poem, user: user)
        } else {
            self.poems[index].likers.updateValue(true, forKey: user.uid)
            self.poems[index].isLike = true
            completion(self.poems[index])
            self.poemsStore.onNext(self.poems)
            self.poemRepository.addLikesToPoem(poem: poem, user: user)
        }
    }
    
    func createTempPoem(poem: Poem, completion: @escaping ((String) -> Void)) {
       
        poem.isTemp = true
        self.poemRepository.createPoem(poemModel: poem) { result in
            switch result {
            case .success(let s):
                self.poems.append(poem)
                self.poemsStore.onNext(self.poems)
                completion(s.rawValue)
            case .failure(let e):
                completion(e.localizedDescription)
            }
        }
    }
    
    func editTempPoem(poem: Poem, completion: @escaping ((String) -> Void)) {

        poem.isTemp = true
        self.poemRepository.editTempSavedPoem(poemModel: poem) { result in
            switch result {
            case .success(let s):
                guard let index = self.poems.firstIndex(of: poem) else { return }
                self.poems[index] = poem
                self.poemsStore.onNext(self.poems)
                completion(s.rawValue)
            case .failure(let e):
                completion(e.localizedDescription)
            }
        }
    }
    
    func fetchEditedPoem(poems: [Poem], poem: Poem) -> Poem {
        guard let index = poems.firstIndex(of: poem) else {return poem}
        return poems[index]
    }
    
    func sortPoemsByLikeCount_Random(_ poems: [Poem]) -> [Poem] {
        //하나만 처리
        if poems.count > 3 {
            let sorted = poems.sorted { p1, p2 in
                p1.likers.count > p2.likers.count
            }
            let prefix = sorted.prefix(3)
            let rest = sorted.dropFirst(3).shuffled()
            return prefix + rest
        } else {
            return poems.sorted { p1, p2 in
                p1.likers.count > p2.likers.count
            }
        }
    }
    
    func sortPoemsByLikeCount_Recent(_ poems: [Poem]) -> [Poem] {
        //하나처리
        if poems.count > 3 {
            let sorted = poems.sorted { p1, p2 in
                p1.likers.count > p2.likers.count
            }
            let prefix = sorted.prefix(3)
            let rest = sorted.dropFirst(3).sorted { p1, p2 in
                p1.uploadAt.timeIntervalSinceReferenceDate > p2.uploadAt.timeIntervalSinceReferenceDate
            }
            return prefix + rest
        } else {
            return poems.sorted { p1, p2 in
                p1.likers.count > p2.likers.count
            }
        }
    }
    
    
    func fetchTempSavedPoem(poems: [Poem], currentUser: User) -> [Poem] {
        
        let filteredPoems = poems.filter { poem in
            return (poem.userUID == currentUser.uid) && (poem.isTemp == true)
        }
        return filteredPoems
    }
    
    func updatePenname(userResisterRepository: UserRegisterRepository, logInUser: CurrentAuth) {
        
        var userWritings = [Poem]()
        
        for poem in self.poems {
            if poem.userUID == logInUser.userUID {
                poem.userPenname = logInUser.userPenname
                userWritings.append(poem)
            }
            self.poemsStore.onNext(self.poems)
            
            if userWritings.isEmpty == false {
                self.poemRepository.updatePenname(poems: userWritings, currentAuth: logInUser)
            }
        }
    }
    
    func filterPoemsForPublic(_ poems: [Poem]) -> [Poem] {
        let filteredPoems = poems.filter{$0.isPrivate == false}.filter{$0.isTemp == false}
        return filteredPoems
    }
    
    func filterBlockedPoem(_ poems: [Poem]) -> [Poem]{
        
        let filteredPoems = poems.filter { poem in
            return self.blockedUserList.contains(poem.userUID) == false
        }.filter{$0.isBlocked == false}
        
        return filteredPoems
    }
    
    func reportPoem(poem: Poem, currentUser: User?, completion: @escaping (() -> Void)){
      
        let filteredPoem = self.poems.filter{$0.id != poem.id}
        self.poemsStore.onNext(filteredPoem)
        
        guard currentUser != nil else { completion()
            return}
        
        self.poemRepository.reportPoem(poem: poem, currentUser: currentUser) {
            completion()
        }
    }
    
    func blockWriter(poem: Poem, currentUser: User, completion: @escaping (()-> Void)) {
        
        self.blockedUserList.append(poem.userUID)
        let filteredPoem = self.poems.filter{$0.userUID != poem.userUID}
        self.poemsStore.onNext(filteredPoem)
        
        self.poemRepository.blockWriter(poem: poem, currentUser: currentUser) {
            completion()
        }
    }
    
    
}
