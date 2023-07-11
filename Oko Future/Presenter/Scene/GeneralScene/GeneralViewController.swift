//
//  ViewController.swift
//  Oko Future
//
//  Created by Denis on 23.03.2023.
//

import UIKit
import RealityKit
import ARKit
import Combine
import AVFoundation

enum AvatarMode {
    case general
    case wardrobe
}

enum AnimationMode {
    case waiting
    case emoji
}

protocol GeneralSceneViewProtocol: UIViewController {
    
    func changeStateSwitch(state: Bool)
}

final class GeneralViewController: UIViewController {
    
    var arView: ARView!
    
    var presenter: GeneralScenePresenterDelegate!
    
    private let sideNavButton: CGFloat = 48
    private let sideSysButton: CGFloat = 64
    private let sideSysBigButton: CGFloat = 72
    
    private let arSwitch: OkoBigSwitch = {
        let sw = OkoBigSwitch()
        return sw
    }()
    
    private let tShirtLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "T-SHIRT"
        lbl.textColor = .white
        return lbl
    }()
    
    private let tShirtEmphasize: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let level1Button: OkoDefaultButton = {
       let btn = OkoDefaultButton()
        btn.setTitle("1", for: .normal)
        btn.layer.borderColor = Helper().numberContrastColor().cgColor
        btn.setTitleColor(.orange, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 30)
//        btn.titleLabel?.font = Helper().fontChakra500(size: 20)!
        return btn
    }()
    
    private let level2Button: OkoDefaultButton = {
       let btn = OkoDefaultButton()
        btn.setTitle("2", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20)
        return btn
    }()
    
    private let arViewButton: OkoDefaultButton = {
       let btn = OkoDefaultButton()
        btn.setImage(UIImage(named: "ARButton"), for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        return btn
    }()
    
    private let profileSettingButton: OkoDefaultButton = {
       let btn = OkoDefaultButton()
        btn.setImage(UIImage(named: "Group 28"), for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return btn
    }()
    
    deinit {
        print("deinit called GeneralViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        stopSession()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func stopSession() {
        presenter.stopSession()
    }
    
    private func setupView() {
        
        view.addSubview(level1Button)
        view.addSubview(level2Button)
        
        view.addSubview(tShirtLabel)
        view.addSubview(tShirtEmphasize)
        
        view.addSubview(arViewButton)
        view.addSubview(profileSettingButton)
        
        view.addSubview(arSwitch)
        
        level1Button.addTarget(self, action: #selector(tapLevel1), for: .touchUpInside)
        level2Button.addTarget(self, action: #selector(tapLevel2), for: .touchUpInside)
        
        arViewButton.addTarget(self, action: #selector(tapArView), for: .touchUpInside)
        profileSettingButton.addTarget(self, action: #selector(tapProfileButton), for: .touchUpInside)
        
        arSwitch.setOnActive(active: tapZoomOut)
        arSwitch.setOffActive(active: tapZoomIn)
    }
    
    private func setupLayout() {
        view.insertSubview(arView, at: 0)
        arView.frame = view.frame
        
        arViewButton.frame = CGRect(x: view.frame.width - sideNavButton - 21,
                                    y: 61,
                                    width: sideNavButton,
                                    height: sideNavButton)
        
        profileSettingButton.frame = CGRect(x: 20,
                                            y: 61,
                                    width: sideNavButton,
                                    height: sideNavButton)
        
        arSwitch.frame = CGRect(x: sideNavButton + 21 + 10,
                                y: 61,
                                width: view.frame.width - (sideNavButton + 21 + 10) * 2,
                                height: sideNavButton)
        
        switch presenter.returnLevelAr() {
        case 1:
            level1Button.frame = CGRect(x: view.center.x - sideSysBigButton / 2,
                                                    y: view.frame.height - 82 - sideSysBigButton + ((sideSysBigButton - sideSysButton) / 2),
                                                    width: sideSysBigButton,
                                                    height: sideSysBigButton)
            
            level2Button.frame =  CGRect(x: self.view.center.x + self.sideSysBigButton / 2 + 16,
                                                      y: view.frame.height - 82 - sideSysButton,
                                                      width: sideSysButton,
                                                      height: sideSysButton)
        case 2:
            self.level1Button.frame = CGRect(x: self.view.center.x - 16 - self.sideSysButton - (self.sideSysBigButton / 2),
                                                    y: self.view.frame.height - 82 - self.sideSysButton,
                                                    width: self.sideSysButton,
                                                    height: self.sideSysButton)
            
            self.level2Button.frame = CGRect(x: self.view.center.x - self.sideSysBigButton / 2,
                                                          y: self.level2Button.frame.origin.y - ((self.sideSysBigButton - self.sideSysButton) / 2),
                                                          width: self.sideSysBigButton,
                                                          height: self.sideSysBigButton)
        default: break
        }
        
        tShirtLabel.frame = CGRect(x: (view.bounds.width - 65) / 2, y: view.bounds.height - 24 - 42, width: 65, height: 24)
        tShirtEmphasize.frame = CGRect(x: tShirtLabel.frame.origin.x, y: tShirtLabel.frame.origin.y + 26, width: 65, height: 2)
    }
    
    @objc private func tapLevel1() {
        if presenter.isAnimateModeEmoji() {
            return
        }
        
        presenter.tapLevel1()
        
        UIView.animate(withDuration: 0.4, animations: {
            
            self.level1Button.layer.borderColor = Helper().numberContrastColor().cgColor
            self.level1Button.setTitleColor(.orange, for: .normal)
            self.level1Button.titleLabel?.font = .systemFont(ofSize: 30)
            
            self.level2Button.setTitleColor(.white, for: .normal)
            self.level2Button.titleLabel?.font = .systemFont(ofSize: 20)
            self.level2Button.layer.borderColor = UIColor.white.cgColor
            
            self.level1Button.frame = CGRect(x: self.view.center.x - self.sideSysBigButton / 2,
                                                    y: self.level1Button.frame.origin.y - ((self.sideSysBigButton - self.sideSysButton) / 2),
                                                    width: self.sideSysBigButton,
                                                    height: self.sideSysBigButton)
            
            self.level2Button.frame =  CGRect(x: self.view.center.x + self.sideSysBigButton / 2 + 16,
                                                           y: self.view.frame.height - 82 - self.sideSysButton,
                                                           width: self.sideSysButton,
                                                           height: self.sideSysButton)
        })
    }
    
    @objc private func tapLevel2() {
        
        if presenter.isAnimateModeEmoji() {
            return
        }
        
        presenter.tapLevel2()
        
        UIView.animate(withDuration: 0.4, animations: {
            
            self.level2Button.layer.borderColor = Helper().numberContrastColor().cgColor
            self.level2Button.setTitleColor(.orange, for: .normal)
            self.level2Button.titleLabel?.font = .systemFont(ofSize: 30)
            
            self.level1Button.setTitleColor(.white, for: .normal)
            self.level1Button.titleLabel?.font = .systemFont(ofSize: 20)
            self.level1Button.layer.borderColor = UIColor.white.cgColor
            
            self.level1Button.frame = CGRect(x: self.view.center.x - 16 - self.sideSysButton - (self.sideSysBigButton / 2),
                                                    y: self.view.frame.height - 82 - self.sideSysButton,
                                                    width: self.sideSysButton,
                                                    height: self.sideSysButton)
            
            self.level2Button.frame = CGRect(x: self.view.center.x - self.sideSysBigButton / 2,
                                                          y: self.level2Button.frame.origin.y - ((self.sideSysBigButton - self.sideSysButton) / 2),
                                                          width: self.sideSysBigButton,
                                                          height: self.sideSysBigButton)
        })
    }
    
    @objc private func tapArView() {
        
        presenter.tapArView()
    }
    
    @objc private func tapProfileButton() {
        
        presenter.tapUserProfile()
    }
    
    @objc private func tapZoomIn() {
        
        presenter.zoomIn()
    }
    
    @objc private func tapZoomOut() {
        
        presenter.zoomOut()
    }
    
}

extension GeneralViewController: GeneralSceneViewProtocol {
    func changeStateSwitch(state: Bool) {
        arSwitch.isOn = state
    }
    
}

