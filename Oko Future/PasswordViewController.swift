//
//  PasswordViewController.swift
//  Oko Future
//
//  Created by Денис Калинин on 29.05.23.
//

import UIKit

final class PasswordViewController: UIViewController {
    
    private let logoImageView: UIImageView = {
        let img = UIImage(named: "LogoBlack")
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
    
    let interCodeLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Inter code"
        lbl.font = Helper().fontChakra500(size: 16)
        lbl.textColor = .black
        return lbl
    }()
    
    let passwordTextField: UITextField = {
        let txt = UITextField()
        txt.textColor = .black
        txt.backgroundColor = .white
        txt.layer.borderWidth = 1
        txt.layer.borderColor = UIColor.black.cgColor
        txt.textAlignment = .center
        txt.isSecureTextEntry = true
        return txt
    }()
    
    let requestNewCodeLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Request new code"
        lbl.font = Helper().fontChakra500(size: 16)
        lbl.textColor = .black
        return lbl
    }()
    
    let accentLine: UIView = {
        let line = UIView()
        line.backgroundColor = .black
        return line
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
        view.addSubview(interCodeLabel)
        view.addSubview(passwordTextField)
        view.addSubview(requestNewCodeLabel)
        view.addSubview(accentLine)
        
        passwordTextField.addTarget(self, action: #selector(passwordDidChange), for: .editingChanged)
    }
    
    private func setupLayout() {
        let heightOko: CGFloat = 48
        
        logoImageView.frame = CGRect(x: (view.bounds.width - 96)/2, y: 116, width: 96, height: 96)
        logInLabel.frame = CGRect(x: (view.bounds.width - 90)/2, y: logoImageView.frame.origin.y + 96 + 14, width: 90, height: 42)
        
        passwordTextField.frame = CGRect(x: 20, y: view.center.y - 4 - heightOko, width: view.bounds.width - 40, height: heightOko)
        passwordTextField.layer.cornerRadius = passwordTextField.bounds.size.height / 2.0
        
        requestNewCodeLabel.frame = CGRect(x: (view.bounds.width - 141)/2, y: passwordTextField.frame.origin.y + heightOko + 32, width: 141, height: 22)
        
        accentLine.frame = CGRect(x: 192, y: requestNewCodeLabel.frame.origin.y + 22, width: 73, height: 1)
    }
    
    @objc func passwordDidChange(textField: UITextField) {
        
        guard let password = textField.text else { return }
//        guard let user = Helper().getUser() else { return }
        
//        if Helper().passwordСheck(password: password) {
//            /// можно так, можно дать возможность поменять имя далее
////            if user.logInWithApple || user.logInWithGoogle {
////                UploadSceneViewController()
////            }
//
//            let vc = ProfileSettingViewController()
//            navigationController?.pushViewController(vc, animated: true)
//        }
    }
}
