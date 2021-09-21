//
//  NoticeViewModel.swift
//  Poetree
//
//  Created by 김동환 on 2021/09/21.
//

import Foundation
import RxSwift

class NoticeViewModel {
    
    var notices: [Notice]
    let noticeObservable: Observable<[Notice]>
    
    init(notices: [Notice]) {
        self.notices = notices
        self.noticeObservable = Observable.just(notices)
    }
    
}
