//
//  WelcomeViewController.swift
//  Oko Future
//
//  Created by Денис Калинин on 29.05.23.
//

import UIKit

final class WelcomeViewController: UIViewController {
    
    let logoImageView: UIImageView = {
        let img = UIImage(named: "okoLogoColor")
//        let img = UIImage(named: "Welcome")
        let imgV = UIImageView(image: img)
        imgV.contentMode = .scaleAspectFill
        return imgV
    }()
    
//    let welcomeLabel: UILabel = {
//        let lbl = UILabel()
//        lbl.text = "Welcome to"
//        lbl.font = Helper().fontChakra500(size: 16)
//        lbl.textColor = .black
//        return lbl
//    }()
//
//    let okoFutureLabel: UILabel = {
//        let lbl = UILabel()
//        lbl.text = "OKO FUTURE"
////        lbl.font = Helper().fontChakra600(size: 32)
//        lbl.font = lbl.font.withSize(32)
//        lbl.textColor = .black
//        return lbl
//    }()
    
    private let welcomeImage: UIImageView = {
        let img = UIImage(named: "Welcome")
        let imgV = UIImageView(image: img)
        imgV.contentMode = .scaleAspectFill
        return imgV
    }()
    
    let getStartButton: OkoBigButton = {
        let btn = OkoBigButton()
        btn.setTitle("Get started", for: .normal)
//        btn.font = Helper().fontChakra500(size: 16)!
        return btn
    }()
    
    override func viewDidLoad() {
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupLayout()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(welcomeImage)
        view.addSubview(logoImageView)
//        view.addSubview(welcomeLabel)
//        view.addSubview(okoFutureLabel)
        view.addSubview(getStartButton)
        
        getStartButton.addTarget(self, action: #selector(tapStartButton), for: .touchUpInside)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupLayout() {
        let heightOko: CGFloat = 48
        
        welcomeImage.frame = view.frame
        
        logoImageView.frame = CGRect(x: (view.bounds.width - 200)/2, y: 80, width: 200, height: 200)
        
//        welcomeLabel.frame = CGRect(x: (view.bounds.width - 91)/2, y: logoImageView.frame.origin.y + 200 + 54, width: 91, height: 22)
//        okoFutureLabel.frame = CGRect(x: (view.bounds.width - 194)/2, y: welcomeLabel.frame.origin.y + 22 + 4, width: 194, height: 42)
        
        getStartButton.frame = CGRect(x: 20, y: view.bounds.height - heightOko - 58, width: view.bounds.width - 40, height: heightOko)
    }
    
    @objc private func tapStartButton() {
        let vc = LogInViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
