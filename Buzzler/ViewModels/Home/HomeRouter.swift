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
}

class HomeRouter {
    
    func perform(_ segue: HomeSegue, from source: UIViewController) {
        switch segue {
        case .post:
            let postVC = HomeRouter.makePostViewController()
            source.navigationController?.pushViewController(postVC, animated: true)
        }
    }
}

// MARK: Helpers
private extension HomeRouter {
    
    static func makePostViewController() -> PostViewController {
        let postVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PostViewController") as! PostViewController

        return postVC
    }
}
