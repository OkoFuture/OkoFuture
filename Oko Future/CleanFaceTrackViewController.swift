//
//  CleanFaceTrackViewController.swift
//  Oko Future
//
//  Created by Денис Калинин on 25.04.23.
//

import ARKit
import UIKit
import RealityKit

final class CleanFaceTrackViewController: UIViewController {
    
    private var emoji: Emoji? = nil {
        didSet {
            if emoji != oldValue, let emoji = emoji {
                self.emoji = emoji
                self.changeVideo(emoji: emoji)
            }
        }
    }
    
    private var arView: ARView
    
//    private var videoPlayer = AVQueuePlayer()
    
    private let arrayNameVideos = ["poker_face_transition", "poker_face", "excited_transition", "excited", "shoced_transition", "shocked__228-1"]
    private var playerItemPokerFace: [AVPlayerItem] = []
    private var playerItemExcited: [AVPlayerItem] = []
    private var playerItemShoced: [AVPlayerItem] = []
    
    private let backButton: OkoDefaultButton = {
        let btn = OkoDefaultButton()
        btn.setImage(UIImage(named: "arrow_back"), for: .normal)
        return btn
    }()
    
    init(arView: ARView) {
        self.arView = arView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arView.session.delegate = self
        
        view.addSubview(backButton)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        dowloadVideos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        backButton.frame = CGRect(x: 21, y: 61, width: 48, height: 48)
        
        arView.removeFromSuperview()
        arView.frame = view.frame
        view.insertSubview(arView, at: 0)
        
        startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopSession()
    }
    
    private func startSession() {
        arView.scene.anchors.removeAll()
        arView.cameraMode = .ar
        
        let configuration = ARFaceTrackingConfiguration()
        arView.session.run(configuration)
    }
    
    func stopSession() {
        arView.session.pause()
        arView.removeFromSuperview()
    }
    
    @objc func back() {
        arView.removeFromSuperview()
        navigationController?.popViewController(animated: true)
    }
    
}

extension CleanFaceTrackViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
        if let faceAnchor = anchors.first as? ARFaceAnchor {
            createOneAnchor(faceAnchor: faceAnchor)
        }
    }

    private func createOneAnchor (faceAnchor: ARFaceAnchor) {
        
        let anchor = AnchorEntity()
        var currentMatrix = faceAnchor.transform
        currentMatrix.columns.3.y = currentMatrix.columns.3.y - 0.25
        
        anchor.transform.matrix = currentMatrix
        
        arView.scene.addAnchor(anchor)
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
                
        if self.arView.scene.anchors.count < 2 {
            return
        }
        
        if let faceAnchor = anchors.first as? ARFaceAnchor {
            changeEmoji(anchor: faceAnchor)
            
            var currentMatrix = faceAnchor.transform
            currentMatrix.columns.3.y = currentMatrix.columns.3.y - 0.25
            
            arView.scene.anchors[1].transform.matrix = currentMatrix
        }
    }
    
    func changeEmoji(anchor: ARFaceAnchor) {
                let smileLeft = anchor.blendShapes[.mouthSmileLeft]
                let smileRight = anchor.blendShapes[.mouthSmileRight]
                let innerUp = anchor.blendShapes[.browInnerUp]
//                let tongue = anchor.blendShapes[.tongueOut]
//                let cheekPuff = anchor.blendShapes[.cheekPuff]
//                let eyeBlinkLeft = anchor.blendShapes[.eyeBlinkLeft]
                let jawOpen = anchor.blendShapes[.jawOpen]
                
        let shoced: Bool = ((jawOpen?.decimalValue ?? 0.0) + (innerUp?.decimalValue ?? 0.0)) > 0.6
        let excited: Bool = ((smileLeft?.decimalValue ?? 0.0) + (smileRight?.decimalValue ?? 0.0)) > 0.9
        
        if shoced {
            self.emoji = .shoced
        } else if excited {
            self.emoji = .excited
        } else {
            self.emoji = .pokerFace
        }
    }
    
    private func dowloadVideos() {
        
        if playerItemPokerFace.isEmpty {
            for i in 0...1 {
                guard let playerItem = dowloadPlayerItem(index: i) else {return}
                playerItemPokerFace.append(playerItem)
            }
        }

        if playerItemExcited.isEmpty {
            for i in 2...3 {
                guard let playerItem = dowloadPlayerItem(index: i) else {return}
                playerItemExcited.append(playerItem)
            }
        }

        if playerItemShoced.isEmpty {
            for i in 4...5 {
                guard let playerItem = dowloadPlayerItem(index: i) else {return}
                playerItemShoced.append(playerItem)
            }
        }
    }
    
    private func dowloadPlayerItem(index: Int) -> AVPlayerItem? {
        let nameVideo = arrayNameVideos[index]
        
        guard let path = Bundle.main.path(forResource: nameVideo, ofType: "mov") else {
            print("Failed get path", nameVideo)
            return nil
        }
        
        let videoURL = URL(fileURLWithPath: path)
        let url = try? URL.init(resolvingAliasFileAt: videoURL, options: .withoutMounting)
        
        guard let alphaMovieURL = url else {
            print("Failed get url", nameVideo)
            return nil
        }
        
        let videoAsset = AVURLAsset(url: alphaMovieURL)
        let assetKeys = ["playable"]
        
        return AVPlayerItem(asset: videoAsset, automaticallyLoadedAssetKeys: assetKeys)
    }
    
    private func changeVideo(emoji: Emoji) {
        
        if self.arView.scene.anchors.count < 2 {
            return
        }
        
        var videoPlayer = AVQueuePlayer()
        
        switch emoji {
        case .pokerFace:
            videoPlayer = AVQueuePlayer(items: [playerItemPokerFace[0], playerItemPokerFace[1]])
            playerItemPokerFace.removeAll()
        case .excited:
            videoPlayer = AVQueuePlayer(items: [playerItemExcited[0], playerItemExcited[1]])
            playerItemExcited.removeAll()
        case .shoced:
            videoPlayer = AVQueuePlayer(items: [playerItemShoced[0], playerItemShoced[1]])
            playerItemShoced.removeAll()
        }
        
        arView.scene.anchors[1].children.removeAll()
        
        let videoPlane = returnPlane(videoPlayer: videoPlayer)
        dowloadVideos()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.13, execute: {
            videoPlayer.play()
            self.arView.scene.anchors[1].addChild(videoPlane)
        })
    }
    
    private func returnPlane(videoPlayer: AVQueuePlayer) -> ModelEntity {
        
        let videoMaterial = VideoMaterial(avPlayer: videoPlayer)
        
        let width: Float = 0.3
        let height: Float = 0.3
        
        let videoPlane = ModelEntity(mesh: .generatePlane(width: width, depth: height, cornerRadius: 0), materials: [videoMaterial])
        videoPlane.transform.rotation = simd_quatf(angle: 1.5708, axis: SIMD3(x: 1, y: 0, z: 0))
        videoPlane.transform.translation.z = videoPlane.transform.translation.z + 0.1
        
        return videoPlane
    }

}
