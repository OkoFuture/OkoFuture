//
//  WelcomeViewController.swift
//  Oko Future
//
//  Created by Денис Калинин on 29.05.23.
//

import UIKit
import AVFoundation

protocol WelcomeViewProtocol: AnyObject {
    func loadView()
}


final class WelcomeViewController: UIViewController {
    
//    weak var presenter: WelcomeViewPresenterDelegate?
    var presenter: WelcomeViewPresenterDelegate!
    
    let logoImageView: UIImageView = {
        let img = UIImage(named: "okoLogoColor")
        let imgV = UIImageView(image: img)
        imgV.contentMode = .scaleAspectFill
        return imgV
    }()
    
    private var logoPlayer = AVPlayer()
    private var videoView = UIView()
    
    private let welcomeImage: UIImageView = {
        let img = UIImage(named: "welcomeAlpha")
        let imgV = UIImageView(image: img)
        imgV.contentMode = .scaleAspectFit
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
        setupPlayer()
        logoPlayer.play()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(videoView)
        view.addSubview(welcomeImage)
        view.addSubview(getStartButton)
        
        getStartButton.addTarget(self, action: #selector(tapStartButton), for: .touchUpInside)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupPlayer() {
        guard let player = presenter?.returnWelcomeVideoPlayer() else { return }
        
        logoPlayer = player
        
        let playerLayer = AVPlayerLayer(player: logoPlayer)

        playerLayer.frame = self.videoView.frame
        self.videoView.layer.addSublayer(playerLayer)
    }
    
    private func setupLayout() {
        let heightOko: CGFloat = 48
        
        welcomeImage.frame = view.frame
        
        videoView.frame = view.frame
        
        getStartButton.frame = CGRect(x: 20, y: view.bounds.height - heightOko - 58, width: view.bounds.width - 40, height: heightOko)
        
        logoPlayer.play()
    }
    
    @objc private func tapStartButton() {
        presenter?.tapStartButton()
    }
    
}

extension WelcomeViewController: WelcomeViewProtocol {
    
}
