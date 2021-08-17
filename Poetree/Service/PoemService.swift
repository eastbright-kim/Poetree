//
//  PoemService.swift
//  Poetree
//
//  Created by 김동환 on 2021/08/11.
//

import Foundation
import RxSwift
import Firebase

class PoemService {
    
    private var poems = [Poem]()
    private lazy var poemsStore = BehaviorSubject<[Poem]>(value: poems)
    
    var poemForDetailView = BehaviorSubject<Poem>(value: Poem(id: "", userEmail: "", userNickname: "", title: "", content: "", photoId: 0, uploadAt: Date(), isPrivate: false , likers: ["":true], photoURL: URL(string: "https://firebasestorage.googleapis.com/v0/b/poetree-e472e.appspot.com/o/white%2F2-2.jpg?alt=media&token=3945142a-4a01-431b-9a0c-51ff8ee10538")!)) //
    
    let poemRepository: PoemRepository
    
    init(poemRepository: PoemRepository) {
        self.poemRepository = poemRepository
    }
    func allPoems() -> Observable<[Poem]> {
        return poemsStore
    }
    
    func onePoemForDetailView() -> Observable<Poem> {
        return poemForDetailView
    }
    
    
    func createPoem(poem: Poem, completion: @escaping ((String) -> Void)) {
        
        poemRepository.createPoem(poemModel: poem) { result in
            switch result {
            case .success(let s):
                completion(s.rawValue)
                self.poems.append(poem)
                self.poemsStore.onNext(self.poems)
            case .failure:
                completion("write poem error")
            }
        }
    }
    
    func editPoem(editedPoem: Poem, completion: @escaping((String) -> Void)){
        
        poemRepository.createPoem(poemModel: editedPoem) { result in
            switch result {
            case .success(let s):
                if let index = self.poems.firstIndex(of: editedPoem) {
                    self.poems.remove(at: index)
                    self.poems.insert(editedPoem, at: index)
                    self.poemsStore.onNext(self.poems)
                    self.poemForDetailView.onNext(editedPoem)
                    completion(s.rawValue)
                }
            case .failure:
                completion("write poem error")
            }
        }
    }
    
    
    func fetchPoems(completion: @escaping ([Poem], String) -> Void) {
        
        poemRepository.fetchPoems { poemEntities, result in
            
            let poemModels = poemEntities.map { poemEntity -> Poem in
                let id = poemEntity.id
                let userEmail = poemEntity.userEmail
                let userNickname = poemEntity.userNickname
                let title = poemEntity.title
                let content = poemEntity.content
                let photoId = poemEntity.photoId
                let uploadAt = convertStringToDate(dateFormat: "MMM d", dateString: poemEntity.uploadAt)
                let isPublic = poemEntity.isPublic
                let likers = poemEntity.likers
                let photoURL = URL(string: poemEntity.photoURL)!
                let userUID = Auth.auth().currentUser?.uid
               
                return Poem(id: id, userEmail: userEmail, userNickname: userNickname, title: title, content: content, photoId: photoId, uploadAt: uploadAt, isPrivate: isPublic, likers: likers, photoURL: photoURL, userUID: userUID)
            }
            completion(poemModels, "모든 시 불러오기 성공")
            self.poems = poemModels
            self.poemsStore.onNext(poemModels)
        }
    }
    
    
    func getCurrentDate() -> String {

        let currentDate = convertDateToString(format: "MMM-d", date: Date())
        let current = currentDate.components(separatedBy: "-")
        
        let day = Int(current[1])!
        let week = getWeek(day: day)
        
        return "\(current[0]) \(week)"
    }
    
    func getCurrentWritingTime() -> String {
        
        let monthDay = convertDateToString(format: "M월 d일", date: Date())
        let time = Int(convertDateToString(format: "H", date: Date()))!
        
        let cycle = getCycleString(time: time)
        
        let user = Auth.auth().currentUser?.displayName ?? "user"
        
        return "\(user)님이 \(monthDay) \(cycle)에 보내는 글"
    }

}
