//
//  HomeRouter.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 25..
//  Copyright © 2018년 Maru. All rights reserved.
//

import Foundation
import UIKit

enum HomeSegue {
    case post
    case myPage
}

class HomeRouter {
    
    func perform(_ segue: HomeSegue, from source: UIViewController) {
        switch segue {
        case .post:
            let postVC = HomeRouter.makePostViewController()
            source.navigationController?.pushViewController(postVC, animated: true)
        case .myPage:
            let myPageVC = HomeRouter.makeMyPageViewController()
            source.navigationController?.pushViewController(myPageVC, animated: true)
        }
    }
}

// MARK: Helpers
private extension HomeRouter {
    
    static func makePostViewController() -> PostViewController {
        let postVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        return postVC
    }
    
    static func makeMyPageViewController() -> MyPageViewController {
        let postVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyPageViewController") as! MyPageViewController
        return postVC
    }
}
