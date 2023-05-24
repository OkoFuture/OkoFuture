//
//  LogInViewController.swift
//  Oko Future
//
//  Created by Денис Калинин on 22.05.23.
//

import UIKit

final class LogInViewController: UIViewController {
    
    let logoImageView: UIImageView = {
        let img = UIImage(named: "okoLogoColor")
        let imgV = UIImageView(image: img)
        imgV.contentMode = .scaleAspectFill
        return imgV
    }()
    
    let logInLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Log in"
//        lbl.font = Helper().fontChakra600(size: 32)
        lbl.font = lbl.font.withSize(32)
        lbl.textColor = .black
        return lbl
    }()
    
    let emailLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "E-mail"
        lbl.font = Helper().fontChakra500(size: 16)
        lbl.textColor = .black
        return lbl
    }()
    
    let emailTextField: UITextField = {
        let txt = UITextField()
        txt.textColor = .black
        txt.backgroundColor = .white
        txt.layer.borderWidth = 1
        txt.layer.borderColor = UIColor.black.cgColor
        txt.textAlignment = .center
        return txt
    }()
    
    let sendCodeButton: OkoBigButton = {
        let btn = OkoBigButton()
        btn.setTitle("Send code", for: .normal)
//        btn.font = Helper().fontChakra500(size: 16)!
        return btn
    }()
    
    let signUpLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Or Sign Up with"
        lbl.font = Helper().fontChakra500(size: 16)
        lbl.textColor = .black
        return lbl
    }()
    
    let appleSignUpButton: OkoBigButton = {
        let btn = OkoBigButton()
        btn.setTitle("Apple", for: .normal)
        btn.setImage(UIImage(named: "AppleLogo"), for: .normal)
//        btn.font = Helper().fontChakra500(size: 16)!
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.black.cgColor
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        return btn
    }()
    
    let googleSignUpButton: OkoBigButton = {
        let btn = OkoBigButton()
        btn.setTitle("Google", for: .normal)
        btn.setImage(UIImage(named: "GoogleLogo"), for: .normal)
//        btn.font = Helper().fontChakra500(size: 16)!
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.black.cgColor
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
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
        
        view.addSubview(logoImageView)
        view.addSubview(logInLabel)
        view.addSubview(emailLabel)
        view.addSubview(emailTextField)
        view.addSubview(sendCodeButton)
        view.addSubview(signUpLabel)
        view.addSubview(appleSignUpButton)
        view.addSubview(googleSignUpButton)
        
        sendCodeButton.addTarget(self, action: #selector(tapSendButton), for: .touchUpInside)
    }
    
    private func setupLayout() {
        let heightOko: CGFloat = 48
        
        logoImageView.frame = CGRect(x: (view.bounds.width - 96)/2, y: 116, width: 96, height: 96)
        logInLabel.frame = CGRect(x: (view.bounds.width - 90)/2, y: logoImageView.frame.origin.y + 96 + 14, width: 90, height: 42)
        
        emailTextField.frame = CGRect(x: 20, y: view.center.y - 4 - heightOko, width: view.bounds.width - 40, height: heightOko)
        emailTextField.layer.cornerRadius = emailTextField.bounds.size.height / 2.0
        
        emailLabel.frame = CGRect(x: (view.bounds.width - 60)/2, y: emailTextField.frame.origin.y - 24 - 8, width: 60, height: 24)
        
        sendCodeButton.frame = CGRect(x: 20, y: view.center.y + 4, width: view.bounds.width - 40, height: heightOko)
        
        signUpLabel.frame = CGRect(x: (view.bounds.width - 120)/2, y: view.bounds.height - 178 - 24, width: 120, height: 24)
        
        
        appleSignUpButton.frame = CGRect(x: 20, y: signUpLabel.frame.origin.y + 24 + 16, width: view.bounds.width - 40, height: heightOko)
        googleSignUpButton.frame = CGRect(x: 20, y: appleSignUpButton.frame.origin.y + heightOko + 4, width: view.bounds.width - 40, height: heightOko)
        
    }
    
    @objc private func tapSendButton() {
        let vc = WelcomeViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}