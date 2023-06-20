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
    private var nodeGirl: ModelEntity?
    private var nodeAvatar: ModelEntity?
    
    public var chooseModel = 0
    private var chooseLevel = 1
    
    public let startPoint: SIMD3<Float> = [0, -2, -1]
    public let finishPoint: SIMD3<Float> = [0, -2.3, 0.5]
    public let arrayNameScene = Helper().arrayNameAvatarUSDZ()
    private let arrayNameVideos = ["poker_face_transition", "poker_face", "excited_transition", "excited", "shoced_transition", "shocked__228-1"]
    private var arrayPlayerItem: [AVPlayerItem] = []
    
    private var playerItemPokerFace: [AVPlayerItem] = []
    private var playerItemExcited: [AVPlayerItem] = []
    private var playerItemShoced: [AVPlayerItem] = []
    
    private var videoPlayerEmoji: AVQueuePlayer? = nil
    
//    private var durationZoomCamera: Float = 1
    private var durationZoomCamera: Float = 1.5
    private var timerAnimation: Timer? = nil
    private var animationController: AnimationPlaybackController? = nil
    private var animateMode: AnimationMode = .waiting
    
    private let sideNavButton: CGFloat = 48
    private let sideSysButton: CGFloat = 64
    private let sideSysBigButton: CGFloat = 72
    
    private let serialQueue = DispatchQueue(label: "animate")
    
    private var emojiCounter = 1 {
        didSet {
            if emojiCounter == 4 {
                emojiCounter = 1
            }
        }
    }
    
    private var flexCounter = 1 {
        didSet {
            if flexCounter == 6 {
                flexCounter = 1
            }
        }
    }
    
    private var subAnimComplete: Cancellable? = nil
    
    private let timingStartFlex1:Float = 1/24
    private let timingFinishFlex1:Float = 72/24
    
    private let timingStartFlex2:Float = 72/24
    private let timingFinishFlex2:Float = 144/24
    
    private let timingStartFlex3:Float = 144/24
    private let timingFinishFlex3:Float = 216/24
    
    private let timingStartFlex4:Float = 216/24
    private let timingFinishFlex4:Float = 288/24
    
    private let timingStartFlex5:Float = 288/24
    private let timingFinishFlex5:Float = 360/24
    
    private let timingStartEmoji1:Float = 360/24
    private let timingFinishEmoji1:Float = 455/24
    
    private let timingStartEmoji2:Float = 455/24
    private let timingFinishEmoji2:Float = 550/24
    
    private let timingStartEmoji3:Float = 551/24
    private let timingFinishEmoji3:Float = 647/24
    
    private let timingFinishEmoji5:Float = 840/24
    
    private var dictAnimationRes1 = [String : AnimationResource]()
//    private var dictAnimationRes2 = [String : AnimationResource]()
    
    private var mode: AvatarMode = .general
    
    private var demoEmoji = false
    
    private var videoPlayerPlane = AVPlayer()
    private var videoPlayerScreen = AVPlayer()
    private var videoPlayerOkoBot = AVPlayer()
    
    private var emoji: EmojiLVL2? = nil {
        didSet {
            if emoji != oldValue, let emoji = emoji {
                self.emoji = emoji
//                self.rewindVideoEmoji(emoji: emoji)
            }
        }
    }
    
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
//        btn.setImage(UIImage(named: "istockphoto-1"), for: .normal)
        btn.setTitle("1", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        return btn
    }()
    
    private let level2Button: OkoDefaultButton = {
       let btn = OkoDefaultButton()
//        btn.setImage(UIImage(named: "istockphoto-1"), for: .normal)
        btn.setTitle("2", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        return btn
    }()
    
    private let firstModelWardrobeButton: OkoDefaultButton = {
       let btn = OkoDefaultButton()
        btn.setImage(UIImage(named: "istockphoto-1"), for: .normal)
        btn.isEnabled = false
        return btn
    }()
    
    private let secondModelWardrobeButton: OkoDefaultButton = {
       let btn = OkoDefaultButton()
        btn.setImage(UIImage(named: "istockphoto-2"), for: .normal)
        btn.isEnabled = false
        return btn
    }()
    
    private let arViewButton: OkoDefaultButton = {
       let btn = OkoDefaultButton()
        btn.setImage(UIImage(named: "view_in_ar"), for: .normal)
        return btn
    }()
    
    private let profileSettingButton: OkoDefaultButton = {
       let btn = OkoDefaultButton()
        btn.setTitle("P", for: .normal)
        return btn
    }()
    
    init(arView: ARView, sceneEntity: ModelEntity, nodeGirl: ModelEntity, nodeAvatar: ModelEntity) {
        self.arView = arView
        self.sceneEntity = sceneEntity
        self.nodeGirl = nodeGirl
        self.nodeAvatar = nodeAvatar
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit called GeneralViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        dowloadVideos()
        createAnimRes()
//        subAnim()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
//        startTimerFlex()
        startAnimationFlex()
        subAnim()
        setupLayout()
        
        setupScene()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        stopSession()
        print ("kjjklnklkl", CFGetRetainCount(self))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print ("kjjklnklkl", CFGetRetainCount(self))
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
        
        let Light = Lighting()
        let anchorLight = AnchorEntity(world: self.startPoint)
        arView.scene.addAnchor(anchorLight)
        let pointLight = Lighting().light
        let strongLight = Light.strongLight()
        
        let light1 = AnchorEntity(world: [0,1,0])
        light1.components.set(pointLight)
        anchorLight.addChild(light1)
        
        let light2 = AnchorEntity(world: [0,-0.5,0])
        light2.components.set(strongLight)
        anchorLight.addChild(light2)
        
        let lightFon1 = AnchorEntity(world: [1,1,-2])
        lightFon1.components.set(pointLight)
        anchorLight.addChild(lightFon1)
        
        let lightFon2 = AnchorEntity(world: [-1,2,-2])
        lightFon2.components.set(pointLight)
        anchorLight.addChild(lightFon2)
        
        let lightFon3 = AnchorEntity(world: [-1,1,-2])
        lightFon3.components.set(strongLight)
        anchorLight.addChild(lightFon3)
    }
    
    func stopSession() {
        arView.session.pause()
        self.animationController = nil
        subAnimComplete?.cancel()
//        self.subAnimComplete = nil
        self.timerAnimation?.invalidate()
        self.timerAnimation = nil
    }
    
    private func setupView() {
        
        view.addSubview(level1Button)
        view.addSubview(level2Button)
        
        view.addSubview(tShirtLabel)
        view.addSubview(tShirtEmphasize)
//        view.addSubview(firstModelWardrobeButton)
//        view.addSubview(secondModelWardrobeButton)
        
        view.addSubview(arViewButton)
        view.addSubview(profileSettingButton)
        
        view.addSubview(arSwitch)
        
//        let dragRotateGesture = UIPanGestureRecognizer(target: self, action: #selector(rotateDragY))
//        sceneView.addGestureRecognizer(dragRotateGesture)
        
        level1Button.addTarget(self, action: #selector(tapLevel1), for: .touchUpInside)
        level2Button.addTarget(self, action: #selector(tapLevel2), for: .touchUpInside)
        
        firstModelWardrobeButton.addTarget(self, action: #selector(tapFirst), for: .touchUpInside)
        secondModelWardrobeButton.addTarget(self, action: #selector(tapSecond), for: .touchUpInside)
        
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
        
        switch chooseLevel {
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
        
//        firstModelWardrobeButton.frame = CGRect(x: view.center.x - sideSysBigButton / 2,
//                                                y: view.frame.height - 46 - sideSysBigButton + ((sideSysBigButton - sideSysButton) / 2),
//                                                width: sideSysBigButton,
//                                                height: sideSysBigButton)
//
//        secondModelWardrobeButton.frame =  CGRect(x: self.view.center.x + self.sideSysBigButton / 2 + 16,
//                                                  y: view.frame.height - 46 - sideSysButton,
//                                                  width: sideSysButton,
//                                                  height: sideSysButton)
        
    }
    
    private func createAnimRes() {
        
        if let availableAnimationsGirl = self.nodeGirl?.availableAnimations, self.nodeGirl?.availableAnimations.count != 0 {
            let animGirl = availableAnimationsGirl[0]
            
            let flex1: AnimationResource = try! .generate(with: (animGirl.definition.trimmed(start: .init(timingStartFlex1), end: .init(timingFinishFlex1), duration: nil)))
            let flex2: AnimationResource = try! .generate(with: (animGirl.definition.trimmed(start: .init(timingStartFlex2), end: .init(timingFinishFlex2), duration: nil)))
            let flex3: AnimationResource = try! .generate(with: (animGirl.definition.trimmed(start: .init(timingStartFlex3), end: .init(timingFinishFlex3), duration: nil)))
            let flex4: AnimationResource = try! .generate(with: (animGirl.definition.trimmed(start: .init(timingStartFlex4), end: .init(timingFinishFlex4), duration: nil)))
            let flex5: AnimationResource = try! .generate(with: (animGirl.definition.trimmed(start: .init(timingStartFlex5), end: .init(timingFinishFlex5), duration: nil)))
            
//            let emoji1: AnimationResource = try! .generate(with: (animGirl.definition.trimmed(start: .init(timingStartEmoji1), end: .init(timingFinishEmoji1), duration: nil)))
//            let emoji2: AnimationResource = try! .generate(with: (animGirl.definition.trimmed(start: .init(timingStartEmoji2), end: .init(timingFinishEmoji2), duration: nil)))
//            let emoji3: AnimationResource = try! .generate(with: (animGirl.definition.trimmed(start: .init(timingStartEmoji3), end: .init(timingFinishEmoji3), duration: nil)))
            let emoji1: AnimationResource = try! .generate(with: (animGirl.definition.trimmed(start: .init(timingStartEmoji1), end: .init(timingFinishEmoji3), duration: nil)))
            let emoji2: AnimationResource = try! .generate(with: (animGirl.definition.trimmed(start: .init(timingStartEmoji3), end: .init(timingFinishEmoji5), duration: nil)))
            
            dictAnimationRes1["flex1"] = flex1
            dictAnimationRes1["flex2"] = flex2
            dictAnimationRes1["flex3"] = flex3
            dictAnimationRes1["flex4"] = flex4
            dictAnimationRes1["flex5"] = flex5
            
            dictAnimationRes1["emoji1"] = emoji1
            dictAnimationRes1["emoji2"] = emoji2
//            dictAnimationRes1["emoji1"] = emoji1
//            dictAnimationRes1["emoji2"] = emoji2
//            dictAnimationRes1["emoji3"] = emoji3
        }
        
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
            
//            self.startTimerFlex()
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
            
//            self.startTimerFlex()
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
    
    @objc private func tapLevel1() {
        if self.animateMode == .emoji {
            return
        }
        
        chooseLevel = 1
        
        UIView.animate(withDuration: 0.4, animations: {
            
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
        if self.animateMode == .emoji {
            return
        }
        
        chooseLevel = 2
        
        UIView.animate(withDuration: 0.4, animations: {
            
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
            
            switch chooseLevel {
            case 1: let vc = CleanFaceTrackViewController(arView: self.arView)
                self.navigationController?.pushViewController(vc,
                     animated: true)
            case 2: let vc = LevelTwoViewController(arView: self.arView)
                self.navigationController?.pushViewController(vc,
                     animated: true)
            default: break
            }
            
        } else {
            print ("log ARFaceTrackingConfiguration.isSupported == false")
        }
    }
    
    @objc private func tapProfileButton() {
        let vc = UserProfileViewController()
        self.navigationController?.pushViewController(vc,
             animated: true)
    }
    
    @objc private func tapZoomIn() {
        
        self.stopAnimationFlex()
        
        self.startDemo()
    }
    
    @objc private func tapZoomOut() {
        
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
    
    public func dowloadVideos() {

        for nameVideo in self.arrayNameVideos {
            
            self.arrayPlayerItem.append(returnAVPlayerItem(nameVideo: nameVideo)!)
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
        
        self.durationZoomCamera = 0
        
        self.videoPlayerEmoji?.play()
//        self.videoPlayerEmoji?.rate = 1.3
    }
    
    func generateVideoPlane() {
        
        let nameVideo = "UVmatch_final"
        let item = returnAVPlayerItem(nameVideo: nameVideo)
        
        videoPlayerPlane = AVPlayer(playerItem: item)
        
        let videoMaterial = VideoMaterial(avPlayer: videoPlayerPlane)
        
        nodeGirl?.model?.materials[3] = videoMaterial
        
        videoPlayerPlane.play()
    }
    
    private func generateOkoBot() -> ModelEntity? {
        
        let nameVideo = "okoBotVizor_[000-299]-1"
        let item = returnAVPlayerItem(nameVideo: nameVideo)
        
        videoPlayerOkoBot = AVPlayer(playerItem: item)
        
        let videoMaterial = VideoMaterial(avPlayer: videoPlayerOkoBot)
        videoPlayerOkoBot.play()
        
        let okoRobot1 = try! ModelEntity.loadModel(named: "okobot_2305")
        
        okoRobot1.model?.materials[0] = videoMaterial
        
        return okoRobot1
    }
    
    private func generateScreen() -> ModelEntity? {
        let screen = try! ModelEntity.loadModel(named: "screen_2405")
        
        let scale: Float = 10
        screen.scale = [scale,scale,scale]
        
        let nameVideo = "flip_vert_[000-299]-1"
        let item = returnAVPlayerItem(nameVideo: nameVideo)
        
        videoPlayerScreen = AVPlayer(playerItem: item)
        videoPlayerScreen.play()
        
        let videoMaterial = VideoMaterial(avPlayer: videoPlayerScreen)
//        videoPlayerScreen.play()
        screen.model?.materials[1] = videoMaterial
        
        return screen
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
        
        switch self.chooseModel {
        case 0:
            if let animRes = self.dictAnimationRes1["flex1"] {
                self.animationController = self.nodeGirl?.playAnimation(animRes)
            }
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
        /// может тут сабака зарыта
//        subAnimComplete = arView.scene.subscribe(to: AnimationEvents.PlaybackCompleted.self, on: nil, { event in
        subAnimComplete = arView.scene.subscribe(to: AnimationEvents.PlaybackCompleted.self, on: self.nodeGirl, { event in
            
            /// может тут сабака зарыта
//            print ("klmnkmljnkl", event.playbackController ==)
            
            self.serialQueue.sync {
            
            switch self.animateMode {
            case .waiting:
                
                let flex = "flex" + String(self.flexCounter)
                print ("awdhjbjhbhj", flex)
                
                self.animationController = self.nodeGirl?.playAnimation(self.dictAnimationRes1[flex]!)
                
                self.flexCounter += 1
                
            case .emoji:
                
                let emoji = "emoji" + String(self.emojiCounter)
                print ("awdhjbjhbhj", emoji)
                    
//                    self.videoPlayerEmoji?.advanceToNextItem()
                    /// конец
//                    NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: self.videoPlayerEmoji.currentItem)
                    
                    switch self.chooseLevel {
                    case 1: self.animationController = self.nodeGirl?.playAnimation(self.dictAnimationRes1["emoji1"]!)
                        self.animationController?.speed = 1.4
                    case 2: self.animationController = self.nodeGirl?.playAnimation(self.dictAnimationRes1["emoji2"]!)
                    default: break
                    }
                self.emojiCounter += 1
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
        print ("debag debag startAnimationEmoji")
        
        self.serialQueue.sync {
        
            self.timerAnimation = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
                
                self.durationZoomCamera += 0.01
                
                if self.durationZoomCamera >= (self.timingFinishEmoji1 - self.timingStartEmoji1) {
                    self.durationZoomCamera = 0
                }
            }
            
            self.animateMode = .emoji
        }
    }
    
    private func stopAnimationEmoji() {
        self.serialQueue.sync {
            
            self.emojiCounter = 1
            self.animateMode = .waiting
        
            timerAnimation?.invalidate()
            timerAnimation = nil
        }
    }
    
    private func stopDemo() {
        self.stopAnimationEmoji()
        
        switch chooseLevel {
        case 1: stopDemoLevel1()
        case 2:
            arView.scene.anchors[0].children[2].removeFromParent()
            arView.scene.anchors[0].children[2].removeFromParent()
            nodeGirl?.model?.materials[3] = (nodeAvatar?.model?.materials[3])!
        default: break
        }
    }
    
    private func stopDemoLevel1() {
        arView.scene.anchors[0].children[2].removeFromParent()
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

