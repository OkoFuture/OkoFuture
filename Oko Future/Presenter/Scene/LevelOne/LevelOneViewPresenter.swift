//
//  LevelOneViewPresenter.swift
//  Oko Future
//
//  Created by Денис Калинин on 29.06.23.
//

import Foundation
import ARKit
import RealityKit

protocol LevelOneViewCoordinatorDelegate: AnyObject {
    func showGeneralScene()
}

protocol LevelOneViewPresenterDelegate: AnyObject {
    func startSession()
    func backButtonTap()
}

final class LevelOneViewPresenter: NSObject {
    
    weak var arView: ARView!
    weak var coordinatorDelegate: LevelOneViewCoordinatorDelegate!
    
    var view: LevelOneViewProtocol
    
    private let classifierService = OkoClassifierService()
    
    private let arrayNameVideos = ["poker_face_transition", "poker_face", "excited_transition", "excited", "shoced_transition", "shocked__228-1"]
    private var playerItemPokerFace: [AVPlayerItem] = []
    private var playerItemExcited: [AVPlayerItem] = []
    private var playerItemShoced: [AVPlayerItem] = []
    
    private var emoji: Emoji? = nil {
        didSet {
            if emoji != oldValue, let emoji = emoji {
                self.emoji = emoji
                self.changeVideo(emoji: emoji)
            }
        }
    }
    
    private var isOKO = false
    
    private var counterSearchImage = 0
    
    init(view: LevelOneViewProtocol, arView: ARView, coordinatorDelegate: LevelOneViewCoordinatorDelegate) {
        self.view = view
        self.arView = arView
        self.coordinatorDelegate = coordinatorDelegate
        super.init()
        
        self.arView.session.delegate = self
        bindToImageClassifierService()
//        setPlayerItem()
        dowloadVideos()
    }
    
    
    private func bindToImageClassifierService() {
      classifierService.onDidUpdateState = { [weak self] state in
        self?.setupWithImageClassifierState(state)
      }
    }
    
    private func setupWithImageClassifierState(_ state: ImageClassifierServiceState) {
        
        var resultLog = ""
      switch state {
      case .startRequest:
          resultLog = "Сlassification in progress"
      case .requestFailed:
          resultLog = "Classification is failed"
      case .receiveResult(let result):
          resultLog = result.description
          
          if result.identifier == "OKO" && result.confidence > 70 {
              if !isOKO {
                  isOKO = true
                  view.updateIsOko(isOKO: isOKO)
              }
//              print ("hjkhjjnk результ", result.identifier , result.confidence, isOKO)
          } else {
//              isOKO = false
//              print ("hjkhjjnk результ", result.identifier , result.confidence, isOKO)
          }
      }
//        print (resultLog)
    }
    /// надо сделать 3-5 попыток на повторную проверку логотипа
    private func searchLogoOkoFuture(pixelBuffer: CVPixelBuffer) {
        counterSearchImage += 1
        
        if isOKO {
            
            if counterSearchImage == 600 {
                counterSearchImage = 0
                
                self.classifierService.classifyImage(pixelBuffer)
            }
            
        } else {
            if counterSearchImage == 30 {
                counterSearchImage = 0
                
                self.classifierService.classifyImage(pixelBuffer)
            }
        }
    }
    
}

extension LevelOneViewPresenter: LevelOneViewPresenterDelegate {
    func backButtonTap() {
        coordinatorDelegate.showGeneralScene()
    }
    
    
    func startSession() {
        arView.cameraMode = .ar
        let configuration = ARFaceTrackingConfiguration()
        arView.session.run(configuration)
    }
}

extension LevelOneViewPresenter: ARSessionDelegate {
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
        if let faceAnchor = anchors.first as? ARFaceAnchor {
            createOneAnchor(faceAnchor: faceAnchor)
        }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
//        if !isOKO {
//            counter += 1
//        }
        searchLogoOkoFuture(pixelBuffer: frame.capturedImage)
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
        
        if !isOKO {
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
        /// цикл срань
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
        
        if !isOKO {
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
