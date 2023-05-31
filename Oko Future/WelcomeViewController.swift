//
//  WelcomeViewController.swift
//  Oko Future
//
//  Created by Денис Калинин on 29.05.23.
//

import UIKit
import AVFoundation

final class WelcomeViewController: UIViewController {
    
    let logoImageView: UIImageView = {
        let img = UIImage(named: "okoLogoColor")
        let imgV = UIImageView(image: img)
        imgV.contentMode = .scaleAspectFill
        return imgV
    }()
    
    private var logoPlayer = AVPlayer()
    private var videoView = UIView()
    
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
        setupPlayer()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(welcomeImage)
        view.addSubview(logoImageView)
        view.addSubview(getStartButton)
//        view.addSubview(videoView)
        
        getStartButton.addTarget(self, action: #selector(tapStartButton), for: .touchUpInside)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupPlayer() {
        guard let path = Bundle.main.path(forResource: "Intro_v4", ofType: "mp4") else {
            print("Failed get path intro_v4")
            return
        }
        
        let videoURL = URL(fileURLWithPath: path)
        let url = try? URL.init(resolvingAliasFileAt: videoURL, options: .withoutMounting)
        
        guard let alphaMovieURL = url else {
            print("Failed get url intro_v4")
            return
        }
        
        let videoAsset = AVURLAsset(url: alphaMovieURL)
        
        let item: AVPlayerItem = .init(asset: videoAsset)
        
        logoPlayer = AVPlayer(playerItem: item)
        
        let playerLayer = AVPlayerLayer(player: logoPlayer)

        playerLayer.frame = self.videoView.frame
        playerLayer.videoGravity = .resizeAspectFill
        self.videoView.layer.addSublayer(playerLayer)
        
        logoPlayer.play()
    }
    
    private func setupLayout() {
        let heightOko: CGFloat = 48
        
        welcomeImage.frame = view.frame
        
        videoView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
        
        logoImageView.frame = CGRect(x: (view.bounds.width - 200)/2, y: 80, width: 200, height: 200)
        
        getStartButton.frame = CGRect(x: 20, y: view.bounds.height - heightOko - 58, width: view.bounds.width - 40, height: heightOko)
        
        logoPlayer.play()
    }
    
    @objc private func tapStartButton() {
        let vc = LogInViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
