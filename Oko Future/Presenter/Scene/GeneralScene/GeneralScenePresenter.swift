//
//  GeneralScenePresenter.swift
//  Oko Future
//
//  Created by Денис Калинин on 27.06.23.
//

import AVFoundation
import UIKit
import Combine
import RealityKit
import ARKit

protocol GeneralSceneViewCoordinatorDelegate: AnyObject {
    func showLevelTwoScene()
    func showLevelOneScene()
    func showUserProfileView()
}

protocol GeneralScenePresenterDelegate: AnyObject {
    
    func showScene()
    func stopSession()
    
    func tapUserProfile()
    func tapArView()
    
    func zoomOut()
    func zoomIn()
    
    func tapLevel1()
    func tapLevel2()
    
    func isAnimateModeEmoji() -> Bool
    func returnLevelAr() -> Int
    
    func setupScene()
}

final class GeneralScenePresenter: NSObject {
    
    weak var arView: ARView!
    weak var coordinatorDelegate: GeneralSceneViewCoordinatorDelegate!
    
    var view: GeneralSceneViewProtocol
    
    private var cameraEntity = PerspectiveCamera()
    private var sceneEntity: ModelEntity?
    private var nodeGirl: ModelEntity?
    private var materialTshirt: Material?
    
    private var okoBot: ModelEntity? = nil
    private var okoScreen: ModelEntity? = nil
    
    public let startPoint: SIMD3<Float> = [0, -2, -1]
    public let finishPoint: SIMD3<Float> = [0, -2.3, 0.5]
    
    private let serialQueue = DispatchQueue(label: "animate")
    private var subAnimComplete: Cancellable? = nil
    
    private var durationZoomCamera: Float = 1.5
    private var timerAnimation: Timer? = nil
    private var animationController: AnimationPlaybackController? = nil
    private var animateMode: AnimationMode = .waiting
    var chooseLevel = 1
    
    private var emojiCounter = 1 {
        didSet {
            if emojiCounter == 4 {
                emojiCounter = 1
            }
        }
    }
    /// сейчас вообще анимации ожидания нет
    private var flexCounter = 1 {
        didSet {
            if flexCounter == 6 {
                flexCounter = 1
            }
        }
    }
    
    private let arrayNameVideos = ["poker_face_transition", "poker_face", "excited_transition", "excited", "shoced_transition", "shocked__228-1"]
    private var videoPlayerEmoji: AVQueuePlayer? = nil
    
    private var arrayPlayerItem: [AVPlayerItem] = []
    
    private var playerItemPokerFace: [AVPlayerItem] = []
    private var playerItemExcited: [AVPlayerItem] = []
    private var playerItemShoced: [AVPlayerItem] = []
    
    private var dictAnimationRes1 = [String : AnimationResource]()
    
    private let timingStartFlex1:Float = 1/24
    private let timingFinishFlex1:Float = 90/24
    private let timingStartEmoji1:Float = 440/24
    private let timingStartEmoji3:Float = 551/24
    private let timingFinishEmoji3:Float = 647/24
    private let timingFinishEmoji5:Float = 840/24
    
    private var videoPlayerPlane = AVPlayer()
    private var videoPlayerScreen = AVPlayer()
    private var videoPlayerOkoBot = AVPlayer()
    
    init(view: GeneralSceneViewProtocol, arView: ARView, coordinatorDelegate: GeneralSceneViewCoordinatorDelegate) {
        self.view = view
        self.arView = arView
        self.coordinatorDelegate = coordinatorDelegate
        super.init()
        self.arView.cameraMode = .nonAR
    }
    
    private func uploadScene() {
        
        let cameraEntity = PerspectiveCamera()
        cameraEntity.camera.fieldOfViewInDegrees = 39
        
        let scaleAvatar: Float = 0.75
        
        let arrayNameScene = Helper().arrayNameAvatarUSDZ()
        
        var cancellable: AnyCancellable? = nil
         
          cancellable = ModelEntity.loadModelAsync(named: "loc_new_textures 08.05")
            .sink(receiveCompletion: { error in
              print("Unexpected error: \(error)")
              cancellable?.cancel()
            }, receiveValue: { entity in
                
                entity.setScale(SIMD3(x: 2, y: 2, z: 2), relativeTo: entity)
                self.sceneEntity = entity
                
                cancellable = ModelEntity.loadModelAsync(named: arrayNameScene[0])
                  .sink(receiveCompletion: { error in
                    print("Unexpected error: \(error)")
                    cancellable?.cancel()
                  }, receiveValue: { entity in

                      entity.setScale(SIMD3(x: scaleAvatar, y: scaleAvatar, z: scaleAvatar), relativeTo: entity)
                      
                      self.nodeGirl = entity
                      self.materialTshirt = entity.model?.materials[3]
                      self.setupScene()
                      self.startSession()
                      
                      cancellable?.cancel()
                  })
            })
        
    }
    
    func setupScene() {
        
        guard let nodeGirl = self.nodeGirl else { return }
        guard let sceneEntity = sceneEntity else { return }
        
        let anchor = AnchorEntity(world: self.startPoint)
        arView.scene.addAnchor(anchor)
        
        anchor.addChild(sceneEntity)
        cameraEntity.camera.fieldOfViewInDegrees = 39
        let cameraAnchor = AnchorEntity(world: .zero)
        cameraAnchor.addChild(cameraEntity)
        cameraAnchor.transform.translation = SIMD3(x: 0, y: 0, z: 4)
               
        arView.scene.addAnchor(cameraAnchor)
        
        nodeGirl.transform.translation = SIMD3(x: 0.07, y: 0.7, z: 0.3)
        
        anchor.addChild(nodeGirl)
        /// убрать, надо поправить индексы в массивах якорей
//        let Light = Lighting()
//        let anchorLight = AnchorEntity(world: self.startPoint)
//        arView.scene.addAnchor(anchorLight)
//        let pointLight = Lighting().light
//        let strongLight = Light.strongLight()
//
//        let light1 = AnchorEntity(world: [0,1,0])
//        light1.components.set(pointLight)
//        anchorLight.addChild(light1)
//
//        let light2 = AnchorEntity(world: [0,-0.5,0])
//        light2.components.set(strongLight)
//        anchorLight.addChild(light2)
//
//        let lightFon1 = AnchorEntity(world: [1,1,-2])
//        lightFon1.components.set(pointLight)
//        anchorLight.addChild(lightFon1)
//
//        let lightFon2 = AnchorEntity(world: [-1,2,-2])
//        lightFon2.components.set(pointLight)
//        anchorLight.addChild(lightFon2)
//
//        let lightFon3 = AnchorEntity(world: [-1,1,-2])
//        lightFon3.components.set(strongLight)
//        anchorLight.addChild(lightFon3)
    }

    private func uploadModelEntity() {
        var cancellableBot: AnyCancellable? = nil
        var cancellableScreen: AnyCancellable? = nil
        
        let scaleAvatar: Float = 1
         
        cancellableBot = ModelEntity.loadModelAsync(named: "okobot_2305")
            .sink(receiveCompletion: { error in
              print("Unexpected error: \(error)")
                cancellableBot?.cancel()
            }, receiveValue: { entity in

                entity.setScale(SIMD3(x: scaleAvatar, y: scaleAvatar, z: scaleAvatar), relativeTo: entity)
                
                self.okoBot = entity
                cancellableBot?.cancel()
            })
        
        cancellableScreen = ModelEntity.loadModelAsync(named: "screen_2405")
          .sink(receiveCompletion: { error in
            print("Unexpected error: \(error)")
              cancellableScreen?.cancel()
          }, receiveValue: { entity in

              entity.setScale(SIMD3(x: scaleAvatar, y: scaleAvatar, z: scaleAvatar), relativeTo: entity)
              
              self.okoScreen = entity

              cancellableScreen?.cancel()
          })
    }
    
    func startSession() {
        createAnimRes()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.subAnim()
        })
    }
    
    func stopSession() {
        arView.session.pause()
        self.animationController = nil
        subAnimComplete?.cancel()
//        self.subAnimComplete = nil
        self.timerAnimation?.invalidate()
        self.timerAnimation = nil
    }
    
    private func subAnim() {
        
        subAnimComplete = arView.scene.subscribe(to: AnimationEvents.PlaybackCompleted.self, on: self.nodeGirl, { event in
            
            self.serialQueue.sync {
            
            switch self.animateMode {
            case .waiting:
                
                self.animationController = self.nodeGirl?.playAnimation(self.dictAnimationRes1["flex1"]!)
                
                self.flexCounter += 1
                
            case .emoji:
                
                let emoji = "emoji" + String(self.emojiCounter)
                print ("awdhjbjhbhj", emoji)
                    
                    switch self.chooseLevel {
                    case 1:
                        
                        if self.emojiCounter == 1 {
                            self.animationController = self.nodeGirl?.playAnimation(self.dictAnimationRes1["emoji1"]!)
//                            self.animationController?.speed = 1.15
                        }
                        
                        if self.emojiCounter == 2 {
                            self.view.changeStateSwitch(state: true)
                        }
                    case 2:
                        if self.emojiCounter == 1 {
                            self.animationController = self.nodeGirl?.playAnimation(self.dictAnimationRes1["flex1"]!)
                        }
                        
                        if self.emojiCounter == 2 {
                            self.animationController = self.nodeGirl?.playAnimation(self.dictAnimationRes1["emoji2"]!)
                        }
                        
                        if self.emojiCounter == 3 {
                            self.view.changeStateSwitch(state: true)
                        }
                        self.animationController?.speed = 1.5
                        
                    default: break
                    }
                self.emojiCounter += 1
            }
            }
        })
    }
    
    private func createAnimRes() {
        
        if let availableAnimationsGirl = self.nodeGirl?.availableAnimations, self.nodeGirl?.availableAnimations.count != 0 {
            let animGirl = availableAnimationsGirl[0]
            
            let flex1: AnimationResource = try! .generate(with: (animGirl.definition.trimmed(start: .init(timingStartFlex1), end: .init(timingFinishFlex1), duration: nil)))
            let emoji1: AnimationResource = try! .generate(with: (animGirl.definition.trimmed(start: .init(timingStartEmoji1), end: .init(timingFinishEmoji3), duration: nil)))
            let emoji2: AnimationResource = try! .generate(with: (animGirl.definition.trimmed(start: .init(timingStartEmoji3), end: .init(timingFinishEmoji5), duration: nil)))
            
            dictAnimationRes1["flex1"] = flex1
            
            dictAnimationRes1["emoji1"] = emoji1
            dictAnimationRes1["emoji2"] = emoji2
        }
        
    }
    
    private func tapZoomOut() {
        
        let transform = Transform(scale: SIMD3(x: 1, y: 1, z: 1), rotation: simd_quatf(angle: 0, axis: SIMD3(x: 0, y: 0, z: 0)), translation: startPoint)
        arView.scene.anchors[0].move(to: transform, relativeTo: nil, duration: TimeInterval(self.durationZoomCamera))
        
        for var light in arView.scene.anchors[2].children {
            let trans: SIMD3<Float> = [startPoint.x - finishPoint.x, startPoint.y - finishPoint.y, startPoint.z - finishPoint.z]
            
            let transLight = Transform(scale: SIMD3(x: 1, y: 1, z: 1), rotation: simd_quatf(angle: 0, axis: SIMD3(x: 0, y: 0, z: 0)), translation: trans)
            
            light.move(to: transLight, relativeTo: light, duration: TimeInterval(self.durationZoomCamera))
        }
        
//        self.durationZoomCamera = 0
        
        self.stopDemo()
        
//        self.startTimerFlex()
    }
    
    private func tapZoomIn() {
        
        self.stopAnimationFlex()
        
        self.startDemo()
    }
    
    private func stopAnimationFlex() {
        self.serialQueue.sync {
            
            timerAnimation?.invalidate()
            timerAnimation = nil
        }
    }
    
    private func startDemo() {
        
        print ("debag debag startDemo")
        
        let transform = Transform(scale: SIMD3(x: 1, y: 1, z: 1), rotation: simd_quatf(angle: 0, axis: SIMD3(x: 0, y: 0, z: 0)), translation: finishPoint)
        arView.scene.anchors[0].move(to: transform, relativeTo: nil, duration: TimeInterval(self.durationZoomCamera))
        
        for var light in arView.scene.anchors[2].children {
            let trans: SIMD3<Float> = [finishPoint.x - startPoint.x, finishPoint.y - startPoint.y, finishPoint.z - startPoint.z]
            
            let transLight = Transform(scale: SIMD3(x: 1, y: 1, z: 1), rotation: simd_quatf(angle: 0, axis: SIMD3(x: 0, y: 0, z: 0)), translation: trans)
            
            light.move(to: transLight, relativeTo: light, duration: TimeInterval(self.durationZoomCamera))
        }
        
        switch chooseLevel {
        case 1: addPlayerEmojiLevel1()
        case 2: addPlayerEmojiLevel2()
        default: break
        }
            
        self.startAnimationEmoji()
    }
    
    private func stopDemo() {
        self.stopAnimationEmoji()
        
        switch chooseLevel {
        case 1: stopDemoLevel1()
        case 2: stopDemoLevel2()
        default: break
        }
    }
    
    private func stopDemoLevel2() {
        guard let materialTshirt = self.materialTshirt else { return }
        
        arView.scene.anchors[0].children[2].removeFromParent()
        arView.scene.anchors[0].children[2].removeFromParent()
        nodeGirl?.model?.materials[3] = materialTshirt
        
        self.okoBot = nil
        self.okoScreen = nil
    }
    
    private func stopDemoLevel1() {
        arView.scene.anchors[0].children[2].removeFromParent()
        arView.scene.anchors[0].children[2].removeFromParent()
            self.videoPlayerEmoji?.pause()
//            self.videoPlayerEmoji?.removeAllItems()
            self.videoPlayerEmoji = nil
            /// переделать эту срань
            self.arrayPlayerItem.removeAll()
            self.dowloadVideos()
    }
    
    private func stopAnimationEmoji() {
//        self.serialQueue.sync {
            
            self.emojiCounter = 1
            self.animateMode = .waiting
        
            timerAnimation?.invalidate()
            timerAnimation = nil
//        }
    }
    
    public func dowloadVideos() {

        for nameVideo in self.arrayNameVideos {
            
            self.arrayPlayerItem.append(returnAVPlayerItem(nameVideo: nameVideo)!)
        }
    }
    
    private func returnAVPlayerItem(nameVideo: String) -> AVPlayerItem? {
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
        
        var item: AVPlayerItem = .init(asset: videoAsset)
        
        return item
    }
    
    private func startAnimationEmoji() {
        print ("debag debag startAnimationEmoji")
        
        self.serialQueue.sync {
        
//            self.timerAnimation = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
//
//                self.durationZoomCamera += 0.01
//
//                if self.durationZoomCamera >= (self.timingFinishEmoji1 - self.timingStartEmoji1) {
//                    self.durationZoomCamera = 0
//                }
//            }
            
            self.animateMode = .emoji
        }
    }
    
    func tapArView() {
        if ARFaceTrackingConfiguration.isSupported {
            /// не удолять
            switch chooseLevel {
            case 1: coordinatorDelegate?.showLevelOneScene()
            case 2: coordinatorDelegate?.showLevelTwoScene()
            default: break
            }
            
        } else {
            
            guard let view = view as? UIViewController else {return}
            view.showAlert(title: "Error", message: "Your device does not support ar mode")
        }
    }
    
    func generateVideoPlane() {
        
        let nameVideo = "Tshirt_lvl2_demo"
        let item = returnAVPlayerItem(nameVideo: nameVideo)
        
        videoPlayerPlane = AVPlayer(playerItem: item)
        
        let videoMaterial = VideoMaterial(avPlayer: videoPlayerPlane)
        
        nodeGirl?.model?.materials[3] = videoMaterial
        
        videoPlayerPlane.play()
        videoPlayerPlane.rate = 0.84
    }
    
    private func generateOkoBot() -> ModelEntity? {
        
        guard let okoBot = self.okoBot else {return nil}
        
        let nameVideo = "okoBotVizor_lvl2_demo"
        let item = returnAVPlayerItem(nameVideo: nameVideo)
        
        videoPlayerOkoBot = AVPlayer(playerItem: item)
        
        let videoMaterial = VideoMaterial(avPlayer: videoPlayerOkoBot)
        videoPlayerOkoBot.play()
        videoPlayerOkoBot.rate = 0.84
        
        okoBot.model?.materials[0] = videoMaterial
        
        return okoBot
    }
    
    private func generateScreen() -> ModelEntity? {
        
        let nameVideo = "flip_vert_[000-299]-1"
        let item = returnAVPlayerItem(nameVideo: nameVideo)
        
        videoPlayerScreen = AVPlayer(playerItem: item)
        videoPlayerScreen.play()
        
        let videoMaterial = VideoMaterial(avPlayer: videoPlayerScreen)
        
        guard let screen = self.okoScreen else {return nil}
        
        let scale: Float = 10
        screen.scale = [scale,scale,scale]
        
        screen.model?.materials[1] = videoMaterial
        
        return screen
    }
    
    private func addPlayerEmojiLevel1() {
        if self.videoPlayerEmoji != nil {
            self.videoPlayerEmoji = nil
        }
        
        videoPlayerEmoji = AVQueuePlayer(items: arrayPlayerItem)
        
        let videoMaterial = VideoMaterial(avPlayer: self.videoPlayerEmoji!)
        
        let backgroundPlane = ModelEntity(mesh: .generatePlane(width: 0.1, depth: 0.07, cornerRadius: 0), materials: [SimpleMaterial(color: .black, isMetallic: false)])
        let videoPlane = ModelEntity(mesh: .generatePlane(width: 0.3, depth: 0.3, cornerRadius: 0), materials: [videoMaterial])
        
        backgroundPlane.transform.translation = SIMD3(x: 0, y: 2.55, z: -0.25)
        backgroundPlane.transform.rotation = simd_quatf(angle: 1.5708, axis: SIMD3(x: 1, y: 0, z: 0))
        
        videoPlane.transform.translation = SIMD3(x: 0, y: 2.55, z: -0.2)
        videoPlane.transform.rotation = simd_quatf(angle: 1.5708, axis: SIMD3(x: 1, y: 0, z: 0))
        
        arView.scene.anchors[0].addChild(videoPlane)
        arView.scene.anchors[0].addChild(backgroundPlane)
        
        let transformVideoPlane = Transform(scale: SIMD3(x: 1, y: 1, z: 1), rotation: simd_quatf(angle: 0, axis: SIMD3(x: 0, y: 0, z: 0)), translation: SIMD3(x: 0, y: 1, z: 0))
            
        videoPlane.move(to: transformVideoPlane, relativeTo: videoPlane, duration: TimeInterval(self.durationZoomCamera))
        backgroundPlane.move(to: transformVideoPlane, relativeTo: backgroundPlane, duration: TimeInterval(self.durationZoomCamera))
        
//        self.durationZoomCamera = 0
        
        self.videoPlayerEmoji?.play()
//        self.videoPlayerEmoji?.rate = 1.3
    }
    
    func addPlayerEmojiLevel2() {
        
        generateVideoPlane()
        guard let okoBot = generateOkoBot() else {return}
        guard let screen = generateScreen() else {return}
        
        screen.transform.translation = [0, 1.7, 0.7]
        
        okoBot.transform.translation = [-0.3, 2.6, 1.5]
        
        let startScale: Float = 0
        okoBot.scale = [startScale, startScale, startScale]
        
        okoBot.playAnimation(okoBot.availableAnimations[0].repeat())
        
        let finalScale: Float = 0.1

        arView.scene.anchors[0].addChild(screen)
        arView.scene.anchors[0].addChild(okoBot)
        
        let transOkoBot = Transform(scale: SIMD3(x: finalScale, y: finalScale, z: finalScale), rotation: simd_quatf(angle: 0, axis: SIMD3(x: 0, y: 0, z: 0)), translation: [-0.3, 0.3, 1.5])
        
        okoBot.move(to: transOkoBot, relativeTo: nil, duration: TimeInterval(2))
    }
    
    private func startAnimationFlex() {

        self.serialQueue.sync {
            
            if let animRes = self.dictAnimationRes1["flex1"] {
                self.animationController = self.nodeGirl?.playAnimation(animRes)
            }
        }
    }
    
}

extension GeneralScenePresenter: GeneralScenePresenterDelegate {
    func returnLevelAr() -> Int {
        return chooseLevel
    }
    
    func tapLevel1() {
        if !isAnimateModeEmoji() {
            chooseLevel = 1
        }
    }
    
    func tapLevel2() {
        if !isAnimateModeEmoji() {
            chooseLevel = 2
        }
    }
    
    func isAnimateModeEmoji() -> Bool {
        return self.animateMode == .emoji
    }
    
    func zoomOut() {
        tapZoomOut()
    }
    
    func zoomIn() {
        tapZoomIn()
    }
    
    func tapUserProfile() {
        coordinatorDelegate.showUserProfileView()
    }
    
    func showScene() {
        uploadScene()
    }
    
}
