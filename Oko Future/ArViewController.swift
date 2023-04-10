//
//  ArViewController.swift
//  Oko Future
//
//  Created by Denis on 23.03.2023.
//

import UIKit
import RealityKit
import ARKit

class ArViewController: UIViewController {
    
    private var arView = ARView()
    private var videoPlayer = AVQueuePlayer()
    private var isVideoCreate = false
    
    private let arrayNameVideos = ["poker_face_transition", "poker_face", "excited_transition", "excited", "shoced_transition", "shocked__228-1"]
    private var playerItemPokerFace: [AVPlayerItem] = []
    private var playerItemExcited: [AVPlayerItem] = []
    private var playerItemShoced: [AVPlayerItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(false, animated:false)
        view.addSubview(arView)
        
        guard let referenceImages = ARReferenceImage.referenceImages(
            inGroupNamed: "rusRap", bundle: nil)
        else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        dowloadVideos()
//        let configuration = ARImageTrackingConfiguration()
        let configuration = ARWorldTrackingConfiguration()
//        let configuration = ARFaceTrackingConfiguration()
//        configuration.isAutoFocusEnabled = true
//        configuration.isWorldTrackingEnabled = true
//        configuration.trackingImages = referenceImages
        configuration.maximumNumberOfTrackedImages = 1
        configuration.userFaceTrackingEnabled = true
        configuration.detectionImages = referenceImages
        
        arView.session.delegate = self
        arView.frame = view.frame
        
        arView.session.run(configuration)
    }
}

extension ArViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
        if let imageAnchor = anchors.first as? ARImageAnchor {
            
            let videoMaterial = VideoMaterial(avPlayer: videoPlayer)
            
            let width = Float(imageAnchor.referenceImage.physicalSize.width * 1.03)
            let height = Float(imageAnchor.referenceImage.physicalSize.height * 1.03)

            let videoPlane = ModelEntity(mesh: .generatePlane(width: width, depth: height, cornerRadius: 0.3), materials: [videoMaterial])
            
            let anchorEntity = AnchorEntity()
            anchorEntity.addChild(videoPlane)
            arView.scene.addAnchor(anchorEntity)
            anchorEntity.transform.matrix = imageAnchor.transform
//            videoPlayer.play()
        }
        
        if let faceAnchor = anchors.first as? ARFaceAnchor {
            
            let anchorEntity = AnchorEntity()
            arView.scene.addAnchor(anchorEntity)
            anchorEntity.transform.matrix = faceAnchor.transform
//            videoPlayer.play()
        }
    }

    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
//                anchors.compactMap { $0 as? ARImageAnchor }.forEach {
//                     let anchorEntity = imageAnchorToEntity[$0]
//                         anchorEntity?.transform.matrix = $0.transform
//                }
                
                if let imageAnchor = anchors.first as? ARImageAnchor {
                    /// найти нужный imageAnchor по id и подправить transform
//                    for anchor in arView.scene.anchors {
//                        if anchor.children.first is ModelEntity{
//                            anchor.transform.matrix = imageAnchor.transform
//                        }
//                    }
                    
                    if imageAnchor.isTracked {
//                        videoPlayer.play()
                    } else {
//                        videoPlayer.pause()
                    }
                }
                
                if let faceAnchor = anchors.first as? ARFaceAnchor {
                    changeEmoji(anchor: faceAnchor)
                }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        /// реализация поиска изображений
    }
    
    func changeEmoji(anchor: ARFaceAnchor) {
                let smileLeft = anchor.blendShapes[.mouthSmileLeft]
                let smileRight = anchor.blendShapes[.mouthSmileRight]
                let innerUp = anchor.blendShapes[.browInnerUp]
                let tongue = anchor.blendShapes[.tongueOut]
                let cheekPuff = anchor.blendShapes[.cheekPuff]
                let eyeBlinkLeft = anchor.blendShapes[.eyeBlinkLeft]
                let jawOpen = anchor.blendShapes[.jawOpen]
                
                var newFacePoseResult = ""
            
                if ((jawOpen?.decimalValue ?? 0.0) + (innerUp?.decimalValue ?? 0.0)) > 0.6 {
                    newFacePoseResult = "😧"
                }
                
                if ((smileLeft?.decimalValue ?? 0.0) + (smileRight?.decimalValue ?? 0.0)) > 0.9 {
//                    newFacePoseResult = "😀"
                    videoPlayer = AVQueuePlayer(items: [playerItemExcited[0], playerItemExcited[1]])
                    videoPlayer.play()
                    playerItemExcited.removeAll()
                }
             
                if innerUp?.decimalValue ?? 0.0 > 0.8 {
                    newFacePoseResult = "😳"
                }
                
                if tongue?.decimalValue ?? 0.0 > 0.08 {
                    newFacePoseResult = "😛"
                }
                
                if cheekPuff?.decimalValue ?? 0.0 > 0.5 {
                    newFacePoseResult = "🤢"
                }
                
                if eyeBlinkLeft?.decimalValue ?? 0.0 > 0.5 {
                    newFacePoseResult = "😉"
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
