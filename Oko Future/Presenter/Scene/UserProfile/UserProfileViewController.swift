//
//  UserProfileViewController.swift
//  Oko Future
//
//  Created by Денис Калинин on 13.06.23.
//

import UIKit
import AuthenticationServices
import Firebase

protocol UserProfileViewProtocol {
    
}

final class UserProfileViewController: UIViewController {
    
    var presenter: UserProfileViewPresenterDelegate!
    
    private let backButton: OkoDefaultButton = {
        let btn = OkoDefaultButton()
        btn.setImage(UIImage(named: "arrow_back"), for: .normal)
        return btn
    }()
    
    let uploadBackView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray
        return view
    }()
    
    let uploadImageView: UIImageView = {
        let img = UIImage(named: "dowloadArrowWhite")
        let imgV = UIImageView(image: img)
        imgV.contentMode = .scaleAspectFill
        return imgV
    }()
    
    private let nameUserLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.textColor = .white
        return lbl
    }()
    
    private let logOutButton: UIOkoProfileSettingButton = {
        let btn = UIOkoProfileSettingButton(size: .big)
        return btn
    }()
    
    private let deleteUserButton: UIOkoProfileSettingButton = {
        let btn = UIOkoProfileSettingButton(size: .big)
        return btn
    }()
    
    override func viewDidLoad() {
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupLayout()
    }
    
    private func setupView() {
        view.backgroundColor = .white.withAlphaComponent(0.72)
        
        view.addSubview(backButton)
        view.addSubview(uploadBackView)
        view.addSubview(uploadImageView)
        view.addSubview(nameUserLabel)
        view.addSubview(logOutButton)
        view.addSubview(deleteUserButton)
        
        nameUserLabel.text = presenter.returnNameUser()
        
        backButton.addTarget(self, action: #selector(backButtonTap), for: .touchUpInside)
        
        let logOutTapGesture = UITapGestureRecognizer(target: self, action: #selector(logOutButtonTap))
        let deleteUserTapGesture = UITapGestureRecognizer(target: self, action: #selector(deleteUserButtonTap))
        
        logOutButton.configureView(image: UIImage(), text: "Log out", tapGesture: logOutTapGesture)
        deleteUserButton.configureView(image: UIImage(), text: "Delete Account", tapGesture: deleteUserTapGesture)
    }
    
    private func setupLayout() {
        let heightOko: CGFloat = 48
        
        backButton.frame = CGRect(x: 21, y: 61, width: heightOko, height: heightOko)
        
        uploadBackView.frame = CGRect(x: (view.bounds.width - 160)/2, y: 130, width: 160, height: 160)
        uploadBackView.layer.cornerRadius = uploadBackView.bounds.size.height / 2.0
        
        uploadImageView.frame.size = CGSize(width: 20, height: 20)
        uploadImageView.center = uploadBackView.center
        
        nameUserLabel.frame = CGRect(x: 0, y: uploadBackView.frame.origin.y + 160 + 22, width: view.bounds.width, height: 50)
        
        logOutButton.frame.origin = CGPoint(x: (view.frame.width - logOutButton.frame.width) / 2, y: 400)
        deleteUserButton.frame.origin = CGPoint(x: (view.frame.width - deleteUserButton.frame.width) / 2, y: 500)
    }
    
    @objc func backButtonTap() {
        presenter.backToGeneralScene()
    }
    
    @objc func logOutButtonTap() {
        presenter.logOut(viewForError: self, delegate: self, presentationContextProvider: self)
    }
    
    @objc func deleteUserButtonTap() {
        
        presenter.deleteUser(viewForError: self, delegate: self, presentationContextProvider: self)
    }
    
}

extension UserProfileViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        presenter.didCompleteWithAuthorization(authorization: authorization)
      
    }

}

extension UserProfileViewController: UserProfileViewProtocol {
    
}
