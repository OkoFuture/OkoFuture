//
//  UserProfileViewController.swift
//  Oko Future
//
//  Created by Денис Калинин on 13.06.23.
//

import UIKit

final class UserProfileViewController: UIViewController {
    
    private let backButton: OkoDefaultButton = {
        let btn = OkoDefaultButton()
        btn.setImage(UIImage(named: "arrow_back"), for: .normal)
        return btn
    }()
    
    private let nameUserLabel: UILabel = {
        let lbl = UILabel()
        return lbl
    }()
    
    private let logOutButton: UIButton = {
       let btn = UIButton()
        return btn
    }()
    
    private let deleteUserButton: UIButton = {
       let btn = UIButton()
        return btn
    }()
    
    override func viewDidLoad() {
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupLayout()
    }
    
    private func setupView() {
        view.addSubview(backButton)
        view.addSubview(nameUserLabel)
        view.addSubview(logOutButton)
        view.addSubview(deleteUserButton)
        
        let user = Helper().getUser()!
        nameUserLabel.text = user.name
        
        backButton.addTarget(self, action: #selector(backButtonTap), for: .touchUpInside)
        logOutButton.addTarget(self, action: #selector(logOutButtonTap), for: .touchUpInside)
        deleteUserButton.addTarget(self, action: #selector(deleteUserButtonTap), for: .touchUpInside)
    }
    
    private func setupLayout() {
        let heightOko: CGFloat = 48
        
        backButton.frame = CGRect(x: 21, y: 61, width: heightOko, height: heightOko)
    }
    
    @objc func backButtonTap() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func logOutButtonTap() {
        Helper().logOut()
    }
    
    @objc func deleteUserButtonTap() {
        Helper().deleteUserFirebase()
    }
    
}
