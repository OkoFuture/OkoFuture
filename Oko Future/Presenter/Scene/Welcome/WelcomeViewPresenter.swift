//
//  WelcomeViewPresenter.swift
//  Oko Future
//
//  Created by Денис Калинин on 27.06.23.
//

import AVFoundation
import UIKit

protocol WelcomeViewCoordinatorDelegate: AnyObject {
    func tapStartButton()
}

protocol WelcomeViewPresenterDelegate: AnyObject {
    func returnWelcomeVideoPlayer() -> AVPlayer?
    func tapStartButton()
}

final class WelcomeViewPresenter {
    let welcomeView: WelcomeViewProtocol
    weak var coordinatorDelegate: WelcomeViewCoordinatorDelegate?
    
    init(welcomeView: WelcomeViewProtocol) {
        self.welcomeView = welcomeView
    }
    
}

extension WelcomeViewPresenter: WelcomeViewPresenterDelegate {
    func tapStartButton() {
        coordinatorDelegate?.tapStartButton()
    }
    
    func returnWelcomeVideoPlayer() -> AVPlayer? {
        guard let path = Bundle.main.path(forResource: "Intro_v3_[0001-0050]-1", ofType: "mov") else {
            print("Failed get path intro_v4")
            return nil
        }
        
        let videoURL = URL(fileURLWithPath: path)
        let url = try? URL.init(resolvingAliasFileAt: videoURL, options: .withoutMounting)
        
        guard let alphaMovieURL = url else {
            print("Failed get url intro_v4")
            return nil
        }
        
        let videoAsset = AVURLAsset(url: alphaMovieURL)
        
        let item: AVPlayerItem = .init(asset: videoAsset)
        
        return AVPlayer(playerItem: item)
    }
    
}
