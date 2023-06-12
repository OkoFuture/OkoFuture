//
//  ProfileSettingViewController.swift
//  Oko Future
//
//  Created by Денис Калинин on 29.05.23.
//

import UIKit

final class ProfileSettingViewController: UIViewController {
    
    let uploadBackView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    let uploadImageView: UIImageView = {
        let img = UIImage(named: "downloadArrow")
        let imgV = UIImageView(image: img)
        imgV.contentMode = .scaleAspectFill
        return imgV
    }()
    
    let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Name"
        lbl.font = Helper().fontChakra500(size: 16)
        lbl.textColor = .black
        return lbl
    }()
    
    let nameTextField: UITextField = {
        let txt = UITextField()
        txt.textColor = .black
        txt.backgroundColor = .white
        txt.layer.borderWidth = 1
        txt.layer.borderColor = UIColor.black.cgColor
        txt.textAlignment = .center
        return txt
    }()
    
    let saveStartButton: OkoBigButton = {
        let btn = OkoBigButton()
        btn.setTitle("Save & Start", for: .normal)
//        btn.font = Helper().fontChakra500(size: 16)!
        return btn
    }()
    
    override func viewDidLoad() {
        
        guard let user = Helper().getUser() else { return }
        nameTextField.text = user.name
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupLayout()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(uploadBackView)
        view.addSubview(uploadImageView)
        view.addSubview(nameLabel)
        view.addSubview(nameTextField)
        view.addSubview(saveStartButton)
        
        saveStartButton.addTarget(self, action: #selector(tapSaveStartButton), for: .touchUpInside)
    }
    
    private func setupLayout() {
        let heightOko: CGFloat = 48
        
        uploadBackView.frame = CGRect(x: (view.bounds.width - 160)/2, y: 130, width: 160, height: 160)
        uploadBackView.layer.cornerRadius = uploadBackView.bounds.size.height / 2.0
        
        uploadImageView.frame.size = CGSize(width: 20, height: 20)
        uploadImageView.center = uploadBackView.center
        
        nameTextField.frame = CGRect(x: 20, y: view.center.y - 4 - heightOko, width: view.bounds.width - 40, height: heightOko)
        nameTextField.layer.cornerRadius = nameTextField.bounds.size.height / 2.0
        
        nameLabel.frame = CGRect(x: (view.bounds.width - 45)/2, y: nameTextField.frame.origin.y - 34, width: 45, height: 24)
        
        saveStartButton.frame = CGRect(x: 20, y: view.center.y + 4, width: view.bounds.width - 40, height: heightOko)
    }
    
    @objc private func tapSaveStartButton() {
        
        guard let name = nameTextField.text else { return }
        
        if name.count == 0 { return }
        
        Helper().updateUserData(typeUserData: .name, userData: name)
        
        let vc = UploadSceneViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
