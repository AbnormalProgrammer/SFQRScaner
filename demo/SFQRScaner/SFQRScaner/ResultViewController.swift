//
//  ResultViewController.swift
//  SFQRScaner
//
//  Created by Stroman on 2021/7/11.
//

import UIKit

class ResultViewController: UIViewController {
    
    deinit {
        self.dismissClosure?()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(self.resultLabel)
        NSLayoutConstraint.init(item: self.resultLabel, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint.init(item: self.resultLabel, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
    }
    
    internal var dismissClosure:(() -> Void)?
    
    lazy private var resultLabel:UILabel = {
        let result:UILabel = UILabel.init()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.textAlignment = .center
        result.textColor = .black
        result.font = UIFont.systemFont(ofSize: 20)
        return result
    }()
    
    internal var resultString:String? {
        set {
            self.resultLabel.text = newValue
        }
        get {
            return self.resultLabel.text
        }
    }
}
