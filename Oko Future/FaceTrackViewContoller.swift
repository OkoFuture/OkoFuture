//
//  FaceTrackViewContoller.swift
//  Oko Future
//
//  Created by Denis on 10.04.2023.
//

import UIKit
import RealityKit
import ARKit

fileprivate enum Emoji {
    case pokerFace, excited, shoced
}

final class FaceTrackViewContoller: UIViewController {
    
    private var emoji: Emoji? = nil {
        didSet {
            if emoji != oldValue, let emoji = emoji {
                self.emoji = emoji
                self.changeVideo(emoji: emoji)
            }
        }
    }
    
    private var arView = ARView()
    private var videoPlayer = AVQueuePlayer()
    
    private let arrayNameVideos = ["poker_face_transition", "poker_face", "excited_transition", "excited", "shoced_transition", "shocked__228-1"]
    private var playerItemPokerFace: [AVPlayerItem] = []
    private var playerItemExcited: [AVPlayerItem] = []
    private var playerItemShoced: [AVPlayerItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dowloadVideos()
        
        self.navigationItem.setHidesBackButton(false, animated:false)
        view.addSubview(arView)
        
        let configuration = ARFaceTrackingConfiguration()
        configuration.maximumNumberOfTrackedFaces = 1
        
        arView.session.delegate = self
        arView.frame = view.frame
        
        arView.session.run(configuration)
    }
}

extension FaceTrackViewContoller: ARSessionDelegate {
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
        if let faceAnchor = anchors.first as? ARFaceAnchor {
//            createTwoAnchor(faceAnchor: faceAnchor)
            createOneAnchor(faceAnchor: faceAnchor)
        }
    }

    private func createOneAnchor (faceAnchor: ARFaceAnchor) {
        
        let anchorEntity = AnchorEntity()
        anchorEntity.transform.matrix = faceAnchor.transform
        
        let videoMaterial = VideoMaterial(avPlayer: videoPlayer)
        let width: Float = 100
        let height: Float = 100
        let videoPlane = ModelEntity(mesh: .generatePlane(width: width, depth: height, cornerRadius: 0), materials: [videoMaterial])
        
        anchorEntity.addChild(videoPlane)
        videoPlane.transform.translation += SIMD3(x: 0, y: 0.3, z: 0)
        
        arView.scene.addAnchor(anchorEntity)
//            let transform = Transform(scale: SIMD3(x: 1, y: 1, z: 1), rotation: simd_quatf(angle: 0, axis: SIMD3(x: 0, y: 0, z: 0)), translation: SIMD3(x: 0, y: 0.3, z: 0))
//            videoPlane.move(to: transform, relativeTo: anchorEntity, duration: 0)
    }
    
    private func createTwoAnchor(faceAnchor: ARFaceAnchor) {
        
            let anchorEntity = AnchorEntity()
            arView.scene.addAnchor(anchorEntity)
            anchorEntity.transform.matrix = faceAnchor.transform
            
            let videoMaterial = VideoMaterial(avPlayer: videoPlayer)
            
            let width: Float = 100
            let height: Float = 100

            let videoPlane = ModelEntity(mesh: .generatePlane(width: width, depth: height, cornerRadius: 0), materials: [videoMaterial])
            
            let videoAnchorEntity = AnchorEntity()
            videoAnchorEntity.addChild(videoPlane)
            arView.scene.addAnchor(videoAnchorEntity)
            videoAnchorEntity.transform.matrix = anchorEntity.transform.matrix
            
            videoAnchorEntity.transform.translation += SIMD3(x: 0, y: 0.3, z: 0)
//            let transform = Transform(scale: SIMD3(x: 1, y: 1, z: 1), rotation: simd_quatf(angle: 0, axis: SIMD3(x: 0, y: 0, z: 0)), translation: SIMD3(x: 0, y: 0.3, z: 0))
//            videoAnchorEntity.move(to: transform, relativeTo: anchorEntity, duration: 0)
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
                
                if let faceAnchor = anchors.first as? ARFaceAnchor {
                    changeEmoji(anchor: faceAnchor)
                    arView.scene.anchors[0].transform.matrix = faceAnchor.transform
                }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        /// реализация поиска изображений
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
        
        switch shoced {
        case true:
            self.emoji = .shoced
        case excited == true:
            self.emoji = .excited
        default:
            self.emoji = .pokerFace
        }
    }
    
    private func changeVideo(emoji: Emoji) {
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
        
        videoPlayer.play()
        dowloadVideos()
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
                guard let playerItem = dowloadPlayerItem(index: i-2) else {return}
                playerItemExcited.append(playerItem)
            }
        }

        if playerItemShoced.isEmpty {
            for i in 4...5 {
                guard let playerItem = dowloadPlayerItem(index: i-4) else {return}
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

}
