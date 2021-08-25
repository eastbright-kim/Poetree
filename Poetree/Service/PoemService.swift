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
    
    let poemRepository: PoemRepository
    
    init(poemRepository: PoemRepository) {
        self.poemRepository = poemRepository
    }
    
    
    func allPoems() -> Observable<[Poem]> {
        return poemsStore
    }
    
    func currentUser() -> User {
        return Auth.auth().currentUser!
    }
    
    func createPoem(poem: Poem, completion: @escaping ((String) -> Void)) {
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
    
    func editPoem(beforeEdited: Poem ,editedPoem: Poem, completion: @escaping((String) -> Void)){
        
        poemRepository.createPoem(poemModel: editedPoem) { result in
            
            switch result {
            case .success(let s):
                //firstIndex where 사용하기
                if let index = self.poems.firstIndex(where: { poem in
                    poem.id == beforeEdited.id
                }) {
                    
                    self.poems.remove(at: index)
                    self.poems.insert(editedPoem, at: index)
                    
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
    
    func fetchPoemForPhotoId(photoId: Int) -> [Poem] {
 
        
        let selectedPoems = self.poems.filter{$0.photoId == photoId}
        return selectedPoems
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

}
