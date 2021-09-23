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
    lazy var poemsStore = BehaviorSubject<[Poem]>(value: poems)
    
    
    let poemRepository: PoemRepository
    
    init(poemRepository: PoemRepository) {
        self.poemRepository = poemRepository
    }
    
    
    func allPoems() -> Observable<[Poem]> {
        return poemsStore
    }
    
    func createPoem(poem: Poem, completion: @escaping ((String) -> Void)) {
        
        if poem.isTemp {
            poem.isTemp = false
            poemRepository.createPoem(poemModel: poem) { result in
                switch result {
                case .success(let s):
                    completion(s.rawValue)
                    guard let index = self.poems.firstIndex(of: poem) else { return }
                    self.poems[index] = poem
                    self.poemsStore.onNext(self.poems)
                case .failure:
                    completion("write poem error")
                }
            }
        } else{
            poemRepository.createPoem(poemModel: poem) { result in
                switch result {
                case .success(let s):
                    completion(s.rawValue)
                    self.poems.insert(poem, at: 0)
                    self.poemsStore.onNext(self.poems)
                case .failure:
                    completion("write poem error")
                }
            }
        }
    }
    
    func fetchUserWriting(poem: [Poem], currentUser: CurrentAuth) -> [Poem] {
        let userWrting = poem.filter { poem in
            poem.userUID == currentUser.userUID
        }.filter{$0.isTemp == false}
        return userWrting
    }
    
    func fetchUserLikedWriting_Sorted(poems: [Poem], currentUser: CurrentAuth) -> [Poem] {
  
        let userLikedPoems = poems.filter { poem in
           poem.likers[currentUser.userUID] ?? false
        }.sorted { p1, p2 in
            p1.likers.count > p2.likers.count
        }.filter { poem in
            poem.isPrivate == false
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
    
    func fetchPoems(completion: @escaping (Complete) -> Void) {
        
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
                let photoURL = URL(string: poemEntity.photoURL)!
                let userUID = poemEntity.userUID
                let isTemp = poemEntity.isTemp
                
                return Poem(id: id, userEmail: userEmail, userNickname: userNickname, title: title, content: content, photoId: photoId, uploadAt: uploadAt, isPrivate: isPrivate, likers: likers, photoURL: photoURL, userUID: userUID, isTemp: isTemp)
            }
            self.poems = poemModels
            self.poemsStore.onNext(poemModels)
            completion(.fetchedPoem)
        }
    }
    
    func fetchPoemsByPhotoId_SortedLikesCount(poems: [Poem], photoId: Int) -> [Poem] {
        
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
    
    func fetchLastWeekPoems() -> [Poem] {
        
        let lowerBoundComp = DateComponents(day: -7)
        let lastMonday = Calendar.current.date(byAdding: lowerBoundComp, to: getThisMonday(myDate: Date()))!
        
        let upperBoundComp = DateComponents(day: 7, second: -1)
        let dealLine = Calendar.current.date(byAdding: upperBoundComp, to: lastMonday)!
        
        let lastWeekPoems = self.poems.filter { poem in
            (lastMonday...dealLine).contains(poem.uploadAt)
        }.sorted {$0.likers.count > $1.likers.count}.prefix(5)
        
        return Array(lastWeekPoems)
    }
    
    
    
    func getThreeTopPoems(_ poems: [Poem]) -> [Poem]{
        
        let sorted = poems.sorted{$0.likers.count > $1.likers.count}.prefix(3)
        
        return Array(sorted)
    }
    
    
    func getCurrentDate() -> String {
        
        let currentDate = convertDateToString(format: "MMM-d", date: Date())
        let current = currentDate.components(separatedBy: "-")
        
        let day = Int(current[1])!
        let week = getWeek(day: day)
        
        return "\(current[0]) \(week)"
    }
    
    func getWritingTimeString(date: Date) -> String {
        
        let monthDay = convertDateToString(format: "M월 d일", date: date)
        let time = Int(convertDateToString(format: "H", date: date))!
        
        let cycle = getCycleString(time: time)
        
        let user = Auth.auth().currentUser?.displayName ?? "user"
        
        return "\(user)님이 \(monthDay) \(cycle)에 보내는 글"
    }
    
    func likeHandle(poem: Poem, user: User, completion: @escaping((Poem) -> Void)){
        
        let poemIndex = self.poems.firstIndex(of: poem)
        
        guard let index = poemIndex else {return}
        
        if self.poems[index].isLike {
            self.poems[index].likers.removeValue(forKey: user.uid)
            self.poems[index].isLike = false
            completion(self.poems[index])
            self.poemsStore.onNext(self.poems)
            self.poemRepository.likeCancel(poem: poem, user: user)
        } else {
            self.poems[index].likers.updateValue(true, forKey: user.uid)
            self.poems[index].isLike = true
            completion(self.poems[index])
            self.poemsStore.onNext(self.poems)
            self.poemRepository.likeAdd(poem: poem, user: user)
        }
    }
    
    func tempCreate(poem: Poem, completion: @escaping ((String) -> Void)) {
       
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
    
    func editTemp(poem: Poem, completion: @escaping ((String) -> Void)) {

        poem.isTemp = true
        self.poemRepository.editPoemFromTemp(poemModel: poem) { result in
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
    
    func fetchMatchedPoem(poems: [Poem], poem: Poem) -> Poem {
        guard let index = poems.firstIndex(of: poem) else {return poem}
        return poems[index]
    }
//
//    func sortPoemsByLikeCount_Random_Public(_ poems: [Poem]) -> [Poem] {
//
//        let publicPoem = poems.filter{$0.isPrivate == false}
//
//        if publicPoem.count > 3 {
//            let sorted = publicPoem.sorted { p1, p2 in
//                p1.likers.count > p2.likers.count
//            }
//            let prefix = sorted.prefix(3)
//            let rest = sorted.dropFirst(3).shuffled()
//            let arr = prefix + rest
//            return arr.filter { $0.isPrivate == false}
//        } else {
//            return publicPoem.sorted { p1, p2 in
//                p1.likers.count > p2.likers.count
//            }
//        }
//    }
    
    func sortPoemsByLikeCount_Random(_ poems: [Poem]) -> [Poem] {
        
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
    
    
    func fetchTempSaved(poems: [Poem], currentUser: User) -> [Poem] {
        
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
    
}
