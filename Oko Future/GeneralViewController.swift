//
//  ViewController.swift
//  Oko Future
//
//  Created by Denis on 23.03.2023.
//

import UIKit
import SceneKit
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

final class GeneralViewController: UIViewController {
    
    public var arView: ARView
    
    private var cameraEntity = PerspectiveCamera()
    private var sceneEntity: ModelEntity
    private var nodeGirl: Entity?
    private var nodeAvatar: Entity?
    
    public var chooseModel = 0
    
    public let startPoint: SIMD3<Float> = [0, -2, -1]
    public let finishPoint: SIMD3<Float> = [0, -2.3, 0.5]
    public let arrayNameScene = ["dressed_avatar_2504.usdz", "dressed_girl_2104.usdz"]
    private let arrayNameVideos = ["poker_face_transition", "poker_face", "excited_transition", "excited", "shoced_transition", "shocked__228-1"]
    private var arrayPlayerItem: [AVPlayerItem] = []
    private var videoPlayerEmoji: AVQueuePlayer? = nil
    
    private var durationZoomCamera: Float = 1
    private var timerAnimation: Timer? = nil
    private var animationController: AnimationPlaybackController? = nil
    private var animToggle: Bool = true
    private var animateMode: AnimationMode = .waiting
    
    private let sideNavButton: CGFloat = 48
    private let sideSysButton: CGFloat = 64
    private let sideSysBigButton: CGFloat = 72
    
    private let serialQueue = DispatchQueue(label: "animate")
    
    private var emojiCounter = 0 {
        didSet {
            if emojiCounter == 3 {
                emojiCounter = 0
            }
        }
    }
    
    private var subAnimComplete: Cancellable? = nil
    
    private let timingStartFlex1:Float = 1/24
    private let timingFinishFlex1:Float = 72/24
    
    private let timingStartFlex2:Float = 72/24
    private let timingFinishFlex2:Float = 144/24
    
    private let timingStartEmoji1:Float = 144/24
    private let timingFinishEmoji1:Float = 155/24
    
    private let timingStartEmoji2:Float = 155/24
    private let timingFinishEmoji2:Float = 165/24
    
    private let timingStartEmoji3:Float = 165/24
    private let timingFinishEmoji3:Float = 175/24
    
    private var dictAnimationRes1 = [String : AnimationResource]()
    private var dictAnimationRes2 = [String : AnimationResource]()
    
    private var mode: AvatarMode = .general
    
    private var demoEmoji = false
    
    private let arSwitch: OkoBigSwitch = {
        let sw = OkoBigSwitch()
        return sw
    }()
    
    private let firstModelWardrobeButton: OkoDefaultButton = {
       let btn = OkoDefaultButton()
        btn.setImage(UIImage(named: "istockphoto-1"), for: .normal)
        return btn
    }()
    
    private let secondModelWardrobeButton: OkoDefaultButton = {
       let btn = OkoDefaultButton()
        btn.setImage(UIImage(named: "istockphoto-2"), for: .normal)
        return btn
    }()
    
    private let arViewButton: OkoDefaultButton = {
       let btn = OkoDefaultButton()
        btn.setImage(UIImage(named: "view_in_ar"), for: .normal)
        return btn
    }()
    
    init(arView: ARView, sceneEntity: ModelEntity, nodeGirl: Entity, nodeAvatar: Entity) {
        self.arView = arView
        self.sceneEntity = sceneEntity
        self.nodeGirl = nodeGirl
        self.nodeAvatar = nodeAvatar
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        dowloadVideos()
        createAnimRes()
        subAnim()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        startTimerFlex()
        startAnimationFlex()
        setupLayout()
        
        setupScene()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        stopSession()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        if self.chooseModel == 0 {
            self.nodeAvatar = nil
        } else {
            self.nodeGirl = nil
        }
    }
    
    private func setupScene() {
        
        guard let nodeAvatar = self.nodeAvatar, let nodeGirl = self.nodeGirl else {return}
        
        let anchor = AnchorEntity(world: self.startPoint)
        arView.scene.addAnchor(anchor)
        
        anchor.addChild(sceneEntity)
        cameraEntity.camera.fieldOfViewInDegrees = 39
        let cameraAnchor = AnchorEntity(world: .zero)
        cameraAnchor.addChild(cameraEntity)
        cameraAnchor.transform.translation = SIMD3(x: 0, y: 0, z: 4)
               
        arView.scene.addAnchor(cameraAnchor)
        
        nodeAvatar.transform.translation = SIMD3(x: 0, y: 0.7, z: 0.3)
        
        nodeGirl.transform.translation = SIMD3(x: 0, y: 0.7, z: 0.3)
        
        anchor.addChild(nodeGirl)
    }
    
    func stopSession() {
        arView.session.pause()
    }
    
    private func setupView() {
        
        view.addSubview(firstModelWardrobeButton)
        view.addSubview(secondModelWardrobeButton)
        
        view.addSubview(arViewButton)
        
        view.addSubview(arSwitch)
        
//        let dragRotateGesture = UIPanGestureRecognizer(target: self, action: #selector(rotateDragY))
//        sceneView.addGestureRecognizer(dragRotateGesture)
        
        firstModelWardrobeButton.addTarget(self, action: #selector(tapFirst), for: .touchUpInside)
        secondModelWardrobeButton.addTarget(self, action: #selector(tapSecond), for: .touchUpInside)
        
        arViewButton.addTarget(self, action: #selector(tapArView), for: .touchUpInside)
        
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
        arSwitch.frame = CGRect(x: sideNavButton + 21 + 10,
                                y: 61,
                                width: view.frame.width - (sideNavButton + 21 + 10) * 2,
                                height: sideNavButton)
        
        firstModelWardrobeButton.frame = CGRect(x: view.center.x - sideSysBigButton / 2,
                                                y: view.frame.height - 46 - sideSysBigButton + ((sideSysBigButton - sideSysButton) / 2),
                                                width: sideSysBigButton,
                                                height: sideSysBigButton)
        
        secondModelWardrobeButton.frame =  CGRect(x: self.view.center.x + self.sideSysBigButton / 2 + 16,
                                                  y: view.frame.height - 46 - sideSysButton,
                                                  width: sideSysButton,
                                                  height: sideSysButton)
        
    }
    
    private func createAnimRes() {
        
        guard let anim1 = self.nodeGirl?.availableAnimations[0] else {return}
        
        let flex1: AnimationResource = try! .generate(with: (anim1.definition.trimmed(start: .init(timingStartFlex1), end: .init(timingFinishFlex1), duration: nil)))
        let flex2: AnimationResource = try! .generate(with: (anim1.definition.trimmed(start: .init(timingStartFlex2), end: .init(timingFinishFlex2), duration: nil)))
        let emoji1: AnimationResource = try! .generate(with: (anim1.definition.trimmed(start: .init(timingStartEmoji1), end: .init(timingFinishEmoji1), duration: nil)))
        let emoji2: AnimationResource = try! .generate(with: (anim1.definition.trimmed(start: .init(timingStartEmoji2), end: .init(timingFinishEmoji2), duration: nil)))
        let emoji3: AnimationResource = try! .generate(with: (anim1.definition.trimmed(start: .init(timingStartEmoji3), end: .init(timingFinishEmoji3), duration: nil)))
        
        dictAnimationRes1["flex1"] = flex1
        dictAnimationRes1["flex2"] = flex2
        dictAnimationRes1["emoji1"] = emoji1
        dictAnimationRes1["emoji2"] = emoji2
        dictAnimationRes1["emoji3"] = emoji3
        
        guard let anim1 = self.nodeAvatar?.availableAnimations[0] else {return}
        
        let flex1av: AnimationResource = try! .generate(with: (anim1.definition.trimmed(start: .init(timingStartFlex1), end: .init(timingFinishFlex1), duration: nil)))
        let flex2av: AnimationResource = try! .generate(with: (anim1.definition.trimmed(start: .init(timingStartFlex2), end: .init(timingFinishFlex2), duration: nil)))
        let emoji1av: AnimationResource = try! .generate(with: (anim1.definition.trimmed(start: .init(timingStartEmoji1), end: .init(timingFinishEmoji1), duration: nil)))
        let emoji2av: AnimationResource = try! .generate(with: (anim1.definition.trimmed(start: .init(timingStartEmoji2), end: .init(timingFinishEmoji2), duration: nil)))
        let emoji3av: AnimationResource = try! .generate(with: (anim1.definition.trimmed(start: .init(timingStartEmoji3), end: .init(timingFinishEmoji3), duration: nil)))
        
        dictAnimationRes2["flex1"] = flex1av
        dictAnimationRes2["flex2"] = flex2av
        dictAnimationRes2["emoji1"] = emoji1av
        dictAnimationRes2["emoji2"] = emoji2av
        dictAnimationRes2["emoji3"] = emoji3av
    }
    
    @objc private func tapFirst() {
        
        if self.animateMode == .emoji {
            return
        }
        
        if self.chooseModel != 0 {
            self.chooseModel = 0
            
            if self.nodeGirl != nil {
                arView.scene.anchors[0].children[1].removeFromParent(preservingWorldTransform: false)
                arView.scene.anchors[0].addChild(self.nodeGirl!)
            } else {
                self.uploadChooseSceneInBackground()
            }
            
            self.startTimerFlex()
            self.startAnimationFlex()
            
            UIView.animate(withDuration: 0.4, animations: {
                
                self.firstModelWardrobeButton.frame = CGRect(x: self.view.center.x - self.sideSysBigButton / 2,
                                                        y: self.firstModelWardrobeButton.frame.origin.y - ((self.sideSysBigButton - self.sideSysButton) / 2),
                                                        width: self.sideSysBigButton,
                                                        height: self.sideSysBigButton)
                
                self.secondModelWardrobeButton.frame =  CGRect(x: self.view.center.x + self.sideSysBigButton / 2 + 16,
                                                               y: self.view.frame.height - 46 - self.sideSysButton,
                                                               width: self.sideSysButton,
                                                               height: self.sideSysButton)
            })
            
        }
    }

    @objc private func tapSecond() {
        
        if self.animateMode == .emoji {
            return
        }
        
        if self.chooseModel != 1 {
            self.chooseModel = 1
            
            if self.nodeAvatar != nil {
                arView.scene.anchors[0].children[1].removeFromParent(preservingWorldTransform: false)
                arView.scene.anchors[0].addChild(self.nodeAvatar!)
            } else {
                self.uploadChooseSceneInBackground()
            }
            
            self.startTimerFlex()
            self.startAnimationFlex()
            
            UIView.animate(withDuration: 0.4, animations: {
                
                self.firstModelWardrobeButton.frame = CGRect(x: self.view.center.x - 16 - self.sideSysButton - (self.sideSysBigButton / 2),
                                                        y: self.view.frame.height - 46 - self.sideSysButton,
                                                        width: self.sideSysButton,
                                                        height: self.sideSysButton)
                
                self.secondModelWardrobeButton.frame = CGRect(x: self.view.center.x - self.sideSysBigButton / 2,
                                                              y: self.secondModelWardrobeButton.frame.origin.y - ((self.sideSysBigButton - self.sideSysButton) / 2),
                                                              width: self.sideSysBigButton,
                                                              height: self.sideSysBigButton)
            })
        }
    }
    
    func uploadChooseSceneInBackground() {
        
        var cancellable: AnyCancellable? = nil
        let scaleAvatar: Float = 1.5
        
        cancellable = ModelEntity.loadModelAsync(named: self.arrayNameScene[self.chooseModel])
          .sink(receiveCompletion: { error in
            print("Unexpected error: \(error)")
            cancellable?.cancel()
          }, receiveValue: { entity in
              
              entity.setScale(SIMD3(x: scaleAvatar, y: scaleAvatar, z: scaleAvatar), relativeTo: entity)

              print ("uploadChooseSceneInBackground")
              
              if self.chooseModel == 0 {
                  self.nodeGirl = entity
              } else {
                  self.nodeAvatar = entity
              }
              
              self.arView.scene.anchors[0].children[1].removeFromParent(preservingWorldTransform: false)
              self.arView.scene.anchors[0].addChild(entity)

              cancellable?.cancel()
          })
    }
    
    @objc private func tapArView() {
        
        if ARFaceTrackingConfiguration.isSupported {
            
            let vc = CleanFaceTrackViewController(arView: self.arView)
            self.navigationController?.pushViewController(vc,
                 animated: true)
        } else {
            print ("log ARFaceTrackingConfiguration.isSupported == false")
        }
    }
    
    @objc private func tapZoomIn() {
        
        self.stopAnimationFlex()
        
        self.startDemo()
    }
    
    @objc private func tapZoomOut() {
        
        let transform = Transform(scale: SIMD3(x: 1, y: 1, z: 1), rotation: simd_quatf(angle: 0, axis: SIMD3(x: 0, y: 0, z: 0)), translation: startPoint)
        arView.scene.anchors[0].move(to: transform, relativeTo: nil, duration: TimeInterval(self.durationZoomCamera))
        self.durationZoomCamera = 0
        
        self.stopDemo()
        
        self.startTimerFlex()
    }
    
    public func dowloadVideos() {
        
        for nameVideo in self.arrayNameVideos {
            guard let path = Bundle.main.path(forResource: nameVideo, ofType: "mov") else {
                print("Failed get path", nameVideo)
                return
            }
            
            let videoURL = URL(fileURLWithPath: path)
            let url = try? URL.init(resolvingAliasFileAt: videoURL, options: .withoutMounting)
            
            guard let alphaMovieURL = url else {
                print("Failed get url", nameVideo)
                return
            }
            
            let videoAsset = AVURLAsset(url: alphaMovieURL)
            let assetKeys = ["playable"]
            
            self.arrayPlayerItem.append(AVPlayerItem(asset: videoAsset, automaticallyLoadedAssetKeys: assetKeys))
        }
    }
    
    private func startDemo() {
        
        let transform = Transform(scale: SIMD3(x: 1, y: 1, z: 1), rotation: simd_quatf(angle: 0, axis: SIMD3(x: 0, y: 0, z: 0)), translation: finishPoint)
        arView.scene.anchors[0].move(to: transform, relativeTo: nil, duration: TimeInterval(self.durationZoomCamera))
        
        if self.videoPlayerEmoji != nil {
            self.videoPlayerEmoji = nil
        }
        
        videoPlayerEmoji = AVQueuePlayer(items: arrayPlayerItem)
        
        let videoMaterial = VideoMaterial(avPlayer: self.videoPlayerEmoji!)
        
        let videoPlane = ModelEntity(mesh: .generatePlane(width: 0.3, depth: 0.3, cornerRadius: 0), materials: [videoMaterial])
        
        videoPlane.transform.translation = SIMD3(x: 0, y: 2.15, z: -0.2)
        videoPlane.transform.rotation = simd_quatf(angle: 1.5708, axis: SIMD3(x: 1, y: 0, z: 0))
        
        arView.scene.anchors[0].addChild(videoPlane)
        
        let transformVideoPlane = Transform(scale: SIMD3(x: 1, y: 1, z: 1), rotation: simd_quatf(angle: 0, axis: SIMD3(x: 0, y: 0, z: 0)), translation: SIMD3(x: 0, y: 1, z: 0))
            
        videoPlane.move(to: transformVideoPlane, relativeTo: videoPlane, duration: TimeInterval(self.durationZoomCamera))
        self.durationZoomCamera = 0
        
        self.videoPlayerEmoji?.play()
            
        self.startAnimationEmoji()
    }
    
    private func startAnimationFlex() {

        self.serialQueue.sync {
        
        switch self.chooseModel {
        case 0:
            self.animationController = self.nodeGirl?.playAnimation(self.dictAnimationRes1["flex1"]!)
        case 1:
            self.animationController = self.nodeAvatar?.playAnimation(self.dictAnimationRes2["flex1"]!)
        default: break
        }
        }
    }
    
    private func startTimerFlex() {
        
        self.serialQueue.sync {
            self.timerAnimation = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                
                self.durationZoomCamera += 0.1
                
                if self.durationZoomCamera >= self.timingFinishFlex1 {
                    self.durationZoomCamera = 0
                }
                
//                print ("timer flex", self.durationZoomCamera)
            }
        }
    }
    
    private func subAnim() {
        
        subAnimComplete = arView.scene.subscribe(to: AnimationEvents.PlaybackCompleted.self, on: nil, { _ in
            
            self.serialQueue.sync {
            
            switch self.animateMode {
            case .waiting:
                
                switch self.chooseModel {
                case 0:
                    if !self.animToggle {
                        self.animationController = self.nodeGirl?.playAnimation(self.dictAnimationRes1["flex1"]!)
                    } else {
                        self.animationController = self.nodeGirl?.playAnimation(self.dictAnimationRes1["flex2"]!)
                    }
                case 1:
                    if !self.animToggle {
                        self.animationController = self.nodeAvatar?.playAnimation(self.dictAnimationRes2["flex1"]!)
                    } else {
                        self.animationController = self.nodeAvatar?.playAnimation(self.dictAnimationRes2["flex2"]!)
                    }
                default: break
                }
                
                self.animToggle.toggle()
                
            case .emoji:
                switch self.chooseModel {
                case 0:
                    if self.emojiCounter == 0 {
                        self.animationController = self.nodeGirl?.playAnimation(self.dictAnimationRes1["emoji1"]!)
                    }

                    if self.emojiCounter == 1 {
                        self.animationController = self.nodeGirl?.playAnimation(self.dictAnimationRes1["emoji2"]!)
                    }

                    if self.emojiCounter == 2 {
                        self.animationController = self.nodeGirl?.playAnimation(self.dictAnimationRes1["emoji3"]!)
                    }
//
                case 1:
                    if self.emojiCounter == 0 {
                        self.animationController = self.nodeAvatar?.playAnimation(self.dictAnimationRes2["emoji1"]!)
                    }

                    if self.emojiCounter == 1 {
                        self.animationController = self.nodeAvatar?.playAnimation(self.dictAnimationRes2["emoji2"]!)
                    }

                    if self.emojiCounter == 2 {
                        self.animationController = self.nodeAvatar?.playAnimation(self.dictAnimationRes2["emoji3"]!)
                    }
                default: break
                }
//                self.videoPlayerEmoji?.play()
                self.animationController?.speed = 0.2
                self.emojiCounter += 1
//                self.videoPlayerEmoji?.advanceToNextItem()
            }
            }
        })
    }
    
    private func stopAnimationFlex() {
        self.serialQueue.sync {
            
            timerAnimation?.invalidate()
            timerAnimation = nil
        }
    }
    
    private func startAnimationEmoji() {
        self.serialQueue.sync {
        
            self.timerAnimation = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
                
                self.durationZoomCamera += 0.01
                
                if self.durationZoomCamera >= (self.timingFinishEmoji1 - self.timingStartEmoji1) * 5 {
                    self.durationZoomCamera = 0
                }
                
//                print ("timer Emoji", self.durationZoomCamera)
            }
            
            self.animateMode = .emoji
        }
    }
    
    private func stopAnimationEmoji() {
        self.serialQueue.sync {
            self.animateMode = .waiting
        
            timerAnimation?.invalidate()
            timerAnimation = nil
        }
    }
    
    private func stopDemo() {
        self.stopAnimationEmoji()
        
        arView.scene.anchors[0].children[2].removeFromParent()
            self.videoPlayerEmoji?.pause()
//            self.videoPlayerEmoji?.removeAllItems()
            self.videoPlayerEmoji = nil
            
            self.arrayPlayerItem.removeAll()
            self.dowloadVideos()
    }
    
    @objc private func rotateDragY(_ gesture: UIPanGestureRecognizer) {
        
//        let point = gesture.translation(in: view)
//        sceneView.scene?.rootNode.runAction(SCNAction.rotateBy(x: 0, y: point.x/10, z: 0, duration: 0))
        
//        let velocity = gesture.velocity(in: view)
//        sceneView.scene?.rootNode.childNodes[1].runAction(SCNAction.rotateBy(x: 0, y: 0, z: velocity.x/1000, duration: 0))
        
//        gesture.setTranslation(.zero, in: view)
    }
    
}

