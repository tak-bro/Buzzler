//
//  DetailPostViewModel.swift
//  Buzzler
//
//  Created by 진형탁 on 01/06/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import NSObject_Rx
import SwiftyJSON

public protocol DetailPostViewModelInputs {
    var loadDetailPostTrigger: PublishSubject<Void> { get }
    func refresh()
}

public protocol DetailPostViewModelOutputs {
    var isLoading: Driver<Bool> { get }
    var elements: Variable<[BuzzlerPost]> { get }
    var selectedViewModel: Driver<DetailPostViewModel> { get }
}

public protocol DetailPostViewModelType {
    var inputs: DetailPostViewModelInputs { get  }
    var outputs: DetailPostViewModelOutputs { get }
}

public class DetailPostViewModel {
    
    init(id: Int) {
        print(id)
    }
}
