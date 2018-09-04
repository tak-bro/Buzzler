//
//  CustomerCenterViewController.swift
//  Buzzler
//
//  Created by 진형탁 on 04/09/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import UIKit

class CustomerCenterViewController: UIViewController {

    @IBOutlet weak var vw_termsConditions: UIView!
    @IBOutlet weak var vw_privacyPolicy: UIView!
    
    @IBOutlet weak var vw_companyName: UIView!
    @IBOutlet weak var vw_ceo: UIView!
    @IBOutlet weak var vw_companyAddress: UIView!
    @IBOutlet weak var vw_companyHome: UIView!
    @IBOutlet weak var vw_registrationNumber: UIView!
    @IBOutlet weak var vw_helper: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = " "
        addThinShadowToNav(from: self)
        setUI()
        setGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "고객센터"
    }
    
    func setUI() {
        setSimpleBorderToView(view: vw_termsConditions)
        setSimpleBorderToView(view: vw_privacyPolicy)
        setSimpleBorderToView(view: vw_companyName)
        setSimpleBorderToView(view: vw_ceo)
        setSimpleBorderToView(view: vw_companyAddress)
        setSimpleBorderToView(view: vw_companyHome)
        setSimpleBorderToView(view: vw_registrationNumber)
        setSimpleBorderToView(view: vw_helper)
    }
    
    func setGesture() {
        let termsAndConditions = UITapGestureRecognizer(target: self, action: #selector(self.pushTermsCondtionsVC(sender:)))
        self.vw_termsConditions.addGestureRecognizer(termsAndConditions)
    }
}

extension CustomerCenterViewController {
    
    func pushTermsCondtionsVC(sender: UITapGestureRecognizer) {
        let termsCondtionsVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "TermsAndConditionsViewController") as! TermsAndConditionsViewController
        self.navigationController?.pushViewController(termsCondtionsVC, animated: true)
    }
}
