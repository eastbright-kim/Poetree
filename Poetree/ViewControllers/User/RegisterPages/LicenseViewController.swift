//
//  LicenseViewController.swift
//  Poetree
//
//  Created by 김동환 on 2021/09/30.
//

import UIKit

class LicenseViewController: UIViewController {

    @IBOutlet weak var agreeBtn: UIButton!
    @IBOutlet weak var disagreeBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.agreeBtn.addTarget(self, action: #selector(processAgree), for: .touchUpInside)
        self.disagreeBtn.addTarget(self, action: #selector(processDisagree), for: .touchUpInside)
        setupBtn()
    }
    
    func setupBtn(){
        
        agreeBtn.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        agreeBtn.layer.cornerRadius = 8
        
        disagreeBtn.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        disagreeBtn.layer.cornerRadius = 8
        
    }

    
    @objc func processAgree() {
        NotificationCenter.default.post(name: NSNotification.Name("Agreed"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func processDisagree() {
        NotificationCenter.default.post(name: NSNotification.Name("DisAgreed"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }

}
