//
//  PostViewModel.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 17..
//  Copyright © 2018년 Maru. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya
import NSObject_Rx

final class PostViewModel {
    
    func writePost(title: String, content: String, imageUrls: [String]) {
        gankApi.request(.writePost(title: title, content: content, imageUrls: imageUrls)) { result in
            // do something with the result (read on for more details)
            print(result)
        }
    }
    
}
