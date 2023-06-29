//
//  ViewController.swift
//  Oko Future
//
//  Created by Denis on 23.03.2023.
//

import UIKit
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

protocol GeneralSceneViewProtocol {
    
    func changeStateSwitch(state: Bool)
}

final class GeneralViewController: UIViewController {
    
    var arView: ARView!
    
    var presenter: GeneralScenePresenterDelegate!
    
//    private var cameraEntity = PerspectiveCamera()
//    private var sceneEntity: ModelEntity
//    private var nodeGirl: ModelEntity?
//    private let materialTshirt: Material

//    private var okoBot: ModelEntity? = nil
//    private var okoScreen: ModelEntity? = nil

//    private var chooseLevel = 1
    
//    public let startPoint: SIMD3<Float> = [0, -2, -1]
//    public let finishPoint: SIMD3<Float> = [0, -2.3, 0.5]
//    public let arrayNameScene = Helper().arrayNameAvatarUSDZ()
//    private let arrayNameVideos = ["poker_face_transition", "poker_face", "excited_transition", "excited", "shoced_transition", "shocked__228-1"]
//    private var arrayPlayerItem: [AVPlayerItem] = []
//
//    private var playerItemPokerFace: [AVPlayerItem] = []
//    private var playerItemExcited: [AVPlayerItem] = []
//    private var playerItemShoced: [AVPlayerItem] = []
//
//    private var videoPlayerEmoji: AVQueuePlayer? = nil
    
//    private var durationZoomCamera: Float = 1
//    private var durationZoomCamera: Float = 1.5
//    private var timerAnimation: Timer? = nil
//    private var animationController: AnimationPlaybackController? = nil
//    private var animateMode: AnimationMode = .waiting
    
    private let sideNavButton: CGFloat = 48
    private let sideSysButton: CGFloat = 64
    private let sideSysBigButton: CGFloat = 72
    
//    private let serialQueue = DispatchQueue(label: "animate")
    
//    private var emojiCounter = 1 {
//        didSet {
//            if emojiCounter == 4 {
//                emojiCounter = 1
//            }
//        }
//    }
//
//    private var flexCounter = 1 {
//        didSet {
//            if flexCounter == 6 {
//                flexCounter = 1
//            }
//        }
//    }
    
    private var subAnimComplete: Cancellable? = nil
    /// мусор, может пригодица
    private let timingStartFlex1:Float = 1/24
//    private let timingFinishFlex1:Float = 72/24
    private let timingFinishFlex1:Float = 90/24
    
    private let timingStartFlex2:Float = 72/24
    private let timingFinishFlex2:Float = 144/24
    
    private let timingStartFlex3:Float = 144/24
    private let timingFinishFlex3:Float = 216/24
    
    private let timingStartFlex4:Float = 216/24
    private let timingFinishFlex4:Float = 288/24
    
    private let timingStartFlex5:Float = 288/24
    private let timingFinishFlex5:Float = 360/24
    
//    private let timingStartEmoji1:Float = 360/24
    private let timingStartEmoji1:Float = 440/24
    private let timingFinishEmoji1:Float = 455/24
    
    private let timingStartEmoji2:Float = 455/24
    private let timingFinishEmoji2:Float = 550/24
    
    private let timingStartEmoji3:Float = 551/24
    private let timingFinishEmoji3:Float = 647/24
    
    private let timingFinishEmoji5:Float = 840/24
    
//    private var dictAnimationRes1 = [String : AnimationResource]()
//    private var dictAnimationRes2 = [String : AnimationResource]()
    
//    private var videoPlayerPlane = AVPlayer()
//    private var videoPlayerScreen = AVPlayer()
//    private var videoPlayerOkoBot = AVPlayer()
    
//    private var emoji: EmojiLVL2? = nil {
//        didSet {
//            if emoji != oldValue, let emoji = emoji {
//                self.emoji = emoji
////                self.rewindVideoEmoji(emoji: emoji)
//            }
//        }
//    }
    
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
    
    init(arView: ARView, sceneEntity: ModelEntity, nodeGirl: ModelEntity) {
//        self.arView = arView
//        self.sceneEntity = sceneEntity
//        self.nodeGirl = nodeGirl
//        self.materialTshirt = (nodeGirl.model?.materials[3])!
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
//        dowloadVideos()
//        createAnimRes()
//        uploadModelEntity()
        
        presenter.showScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
//        startTimerFlex()
//        uploadModelEntity()
//        startAnimationFlex()
//        subAnim()
        setupLayout()
        
//        setupScene()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
//        self.okoBot = nil
//        self.okoScreen = nil
        stopSession()
        print ("kjjklnklkl", CFGetRetainCount(self))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print ("kjjklnklkl", CFGetRetainCount(self))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
//            self.nodeGirl = nil
    }
    
    func stopSession() {
        presenter.stopSession()
//        arView.session.pause()
//        self.animationController = nil
//        subAnimComplete?.cancel()
////        self.subAnimComplete = nil
//        self.timerAnimation?.invalidate()
//        self.timerAnimation = nil
    }
    
    private func setupView() {
        
        view.addSubview(level1Button)
        view.addSubview(level2Button)
        
        view.addSubview(tShirtLabel)
        view.addSubview(tShirtEmphasize)
        
        view.addSubview(arViewButton)
        view.addSubview(profileSettingButton)
        
        view.addSubview(arSwitch)
        
        level1Button.addTarget(self, action: #selector(tapLevel1), for: .touchUpInside)
        level2Button.addTarget(self, action: #selector(tapLevel2), for: .touchUpInside)
        
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
        
        switch presenter.returnLevelAr() {
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
    }
    
//    private func uploadModelEntity() {
//        var cancellableBot: AnyCancellable? = nil
//        var cancellableScreen: AnyCancellable? = nil
//
//        let scaleAvatar: Float = 1
//
//        cancellableBot = ModelEntity.loadModelAsync(named: "okobot_2305")
//            .sink(receiveCompletion: { error in
//              print("Unexpected error: \(error)")
//                cancellableBot?.cancel()
//            }, receiveValue: { entity in
//
//                entity.setScale(SIMD3(x: scaleAvatar, y: scaleAvatar, z: scaleAvatar), relativeTo: entity)
//
//                self.okoBot = entity
//                cancellableBot?.cancel()
//            })
//
//        cancellableScreen = ModelEntity.loadModelAsync(named: "screen_2405")
//          .sink(receiveCompletion: { error in
//            print("Unexpected error: \(error)")
//              cancellableScreen?.cancel()
//          }, receiveValue: { entity in
//
//              entity.setScale(SIMD3(x: scaleAvatar, y: scaleAvatar, z: scaleAvatar), relativeTo: entity)
//
//              self.okoScreen = entity
//
//              cancellableScreen?.cancel()
//          })
//    }
    
//    private func createAnimRes() {
//
//        if let availableAnimationsGirl = self.nodeGirl?.availableAnimations, self.nodeGirl?.availableAnimations.count != 0 {
//            let animGirl = availableAnimationsGirl[0]
//
//            let flex1: AnimationResource = try! .generate(with: (animGirl.definition.trimmed(start: .init(timingStartFlex1), end: .init(timingFinishFlex1), duration: nil)))
////            let flex2: AnimationResource = try! .generate(with: (animGirl.definition.trimmed(start: .init(timingStartFlex2), end: .init(timingFinishFlex2), duration: nil)))
////            let flex3: AnimationResource = try! .generate(with: (animGirl.definition.trimmed(start: .init(timingStartFlex3), end: .init(timingFinishFlex3), duration: nil)))
////            let flex4: AnimationResource = try! .generate(with: (animGirl.definition.trimmed(start: .init(timingStartFlex4), end: .init(timingFinishFlex4), duration: nil)))
////            let flex5: AnimationResource = try! .generate(with: (animGirl.definition.trimmed(start: .init(timingStartFlex5), end: .init(timingFinishFlex5), duration: nil)))
//
////            let emoji1: AnimationResource = try! .generate(with: (animGirl.definition.trimmed(start: .init(timingStartEmoji1), end: .init(timingFinishEmoji1), duration: nil)))
////            let emoji2: AnimationResource = try! .generate(with: (animGirl.definition.trimmed(start: .init(timingStartEmoji2), end: .init(timingFinishEmoji2), duration: nil)))
////            let emoji3: AnimationResource = try! .generate(with: (animGirl.definition.trimmed(start: .init(timingStartEmoji3), end: .init(timingFinishEmoji3), duration: nil)))
//            let emoji1: AnimationResource = try! .generate(with: (animGirl.definition.trimmed(start: .init(timingStartEmoji1), end: .init(timingFinishEmoji3), duration: nil)))
//            let emoji2: AnimationResource = try! .generate(with: (animGirl.definition.trimmed(start: .init(timingStartEmoji3), end: .init(timingFinishEmoji5), duration: nil)))
//
//            dictAnimationRes1["flex1"] = flex1
////            dictAnimationRes1["flex2"] = flex2
////            dictAnimationRes1["flex3"] = flex3
////            dictAnimationRes1["flex4"] = flex4
////            dictAnimationRes1["flex5"] = flex5
//
//            dictAnimationRes1["emoji1"] = emoji1
//            dictAnimationRes1["emoji2"] = emoji2
////            dictAnimationRes1["emoji1"] = emoji1
////            dictAnimationRes1["emoji2"] = emoji2
////            dictAnimationRes1["emoji3"] = emoji3
//        }
//
//    }
    
    @objc private func tapLevel1() {
        if presenter.isAnimateModeEmoji() {
            return
        }
        
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
        
        if presenter.isAnimateModeEmoji() {
            return
        }
        
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
    
    @objc private func tapArView() {
        
        presenter.tapArView()
    }
    
    @objc private func tapProfileButton() {
        
        presenter.tapUserProfile()
    }
    
    @objc private func tapZoomIn() {
        
        presenter.zoomIn()
        
    }
    
    @objc private func tapZoomOut() {
        
        presenter.zoomOut()
    }
    
//    private func returnAVPlayerItem(nameVideo: String) -> AVPlayerItem? {
//        guard let path = Bundle.main.path(forResource: nameVideo, ofType: "mov") else {
//            print("Failed get path", nameVideo)
//            return nil
//        }
//
//        let videoURL = URL(fileURLWithPath: path)
//        let url = try? URL.init(resolvingAliasFileAt: videoURL, options: .withoutMounting)
//
//        guard let alphaMovieURL = url else {
//            print("Failed get url", nameVideo)
//            return nil
//        }
//
//        let videoAsset = AVURLAsset(url: alphaMovieURL)
//
//        var item: AVPlayerItem = .init(asset: videoAsset)
//
//        return item
//    }
//
//    public func dowloadVideos() {
//
//        for nameVideo in self.arrayNameVideos {
//
//            self.arrayPlayerItem.append(returnAVPlayerItem(nameVideo: nameVideo)!)
//        }
//    }
    
//    private func startDemo() {
//
//        print ("debag debag startDemo")
//
//        let transform = Transform(scale: SIMD3(x: 1, y: 1, z: 1), rotation: simd_quatf(angle: 0, axis: SIMD3(x: 0, y: 0, z: 0)), translation: finishPoint)
//        arView.scene.anchors[0].move(to: transform, relativeTo: nil, duration: TimeInterval(self.durationZoomCamera))
//
//        for var light in arView.scene.anchors[2].children {
//            let trans: SIMD3<Float> = [finishPoint.x - startPoint.x, finishPoint.y - startPoint.y, finishPoint.z - startPoint.z]
//
//            let transLight = Transform(scale: SIMD3(x: 1, y: 1, z: 1), rotation: simd_quatf(angle: 0, axis: SIMD3(x: 0, y: 0, z: 0)), translation: trans)
//
//            light.move(to: transLight, relativeTo: light, duration: TimeInterval(self.durationZoomCamera))
//        }
//
//        switch chooseLevel {
//        case 1: addPlayerEmojiLevel1()
//        case 2: addPlayerEmojiLevel2()
//        default: break
//        }
//
//        self.startAnimationEmoji()
//    }
    
//    private func addPlayerEmojiLevel1() {
//        if self.videoPlayerEmoji != nil {
//            self.videoPlayerEmoji = nil
//        }
//
//        videoPlayerEmoji = AVQueuePlayer(items: arrayPlayerItem)
//        
//        let videoMaterial = VideoMaterial(avPlayer: self.videoPlayerEmoji!)
//
//        let backgroundPlane = ModelEntity(mesh: .generatePlane(width: 0.1, depth: 0.07, cornerRadius: 0), materials: [SimpleMaterial(color: .black, isMetallic: false)])
//        let videoPlane = ModelEntity(mesh: .generatePlane(width: 0.3, depth: 0.3, cornerRadius: 0), materials: [videoMaterial])
//
//        backgroundPlane.transform.translation = SIMD3(x: 0, y: 2.55, z: -0.25)
//        backgroundPlane.transform.rotation = simd_quatf(angle: 1.5708, axis: SIMD3(x: 1, y: 0, z: 0))
//
//        videoPlane.transform.translation = SIMD3(x: 0, y: 2.55, z: -0.2)
//        videoPlane.transform.rotation = simd_quatf(angle: 1.5708, axis: SIMD3(x: 1, y: 0, z: 0))
//
//        arView.scene.anchors[0].addChild(videoPlane)
//        arView.scene.anchors[0].addChild(backgroundPlane)
//
//        let transformVideoPlane = Transform(scale: SIMD3(x: 1, y: 1, z: 1), rotation: simd_quatf(angle: 0, axis: SIMD3(x: 0, y: 0, z: 0)), translation: SIMD3(x: 0, y: 1, z: 0))
//
//        videoPlane.move(to: transformVideoPlane, relativeTo: videoPlane, duration: TimeInterval(self.durationZoomCamera))
//        backgroundPlane.move(to: transformVideoPlane, relativeTo: backgroundPlane, duration: TimeInterval(self.durationZoomCamera))
//
////        self.durationZoomCamera = 0
//
//        self.videoPlayerEmoji?.play()
////        self.videoPlayerEmoji?.rate = 1.3
//    }
    
//    func generateVideoPlane() {
//
//        let nameVideo = "Tshirt_lvl2_demo"
//        let item = returnAVPlayerItem(nameVideo: nameVideo)
//
//        videoPlayerPlane = AVPlayer(playerItem: item)
//
//        let videoMaterial = VideoMaterial(avPlayer: videoPlayerPlane)
//
//        nodeGirl?.model?.materials[3] = videoMaterial
//
//        videoPlayerPlane.play()
//        videoPlayerPlane.rate = 0.84
//    }
    
//    private func generateOkoBot() -> ModelEntity? {
//        
//        guard let okoBot = self.okoBot else {return nil}
//        
//        let nameVideo = "okoBotVizor_lvl2_demo"
//        let item = returnAVPlayerItem(nameVideo: nameVideo)
//        
//        videoPlayerOkoBot = AVPlayer(playerItem: item)
//        
//        let videoMaterial = VideoMaterial(avPlayer: videoPlayerOkoBot)
//        videoPlayerOkoBot.play()
//        videoPlayerOkoBot.rate = 0.84
//        
//        okoBot.model?.materials[0] = videoMaterial
//        
//        return okoBot
//    }
//    
//    private func generateScreen() -> ModelEntity? {
//        
//        let nameVideo = "flip_vert_[000-299]-1"
//        let item = returnAVPlayerItem(nameVideo: nameVideo)
//        
//        videoPlayerScreen = AVPlayer(playerItem: item)
//        videoPlayerScreen.play()
//        
//        let videoMaterial = VideoMaterial(avPlayer: videoPlayerScreen)
//        
//        guard let screen = self.okoScreen else {return nil}
//        
//        let scale: Float = 10
//        screen.scale = [scale,scale,scale]
//        
//        screen.model?.materials[1] = videoMaterial
//        
//        return screen
//    }
//    
//    func addPlayerEmojiLevel2() {
//        
//        generateVideoPlane()
//        guard let okoBot = generateOkoBot() else {return}
//        guard let screen = generateScreen() else {return}
//        
//        screen.transform.translation = [0, 1.7, 0.7]
//        
//        okoBot.transform.translation = [-0.3, 2.6, 1.5]
//        
//        let startScale: Float = 0
//        okoBot.scale = [startScale, startScale, startScale]
//        
//        okoBot.playAnimation(okoBot.availableAnimations[0].repeat())
//        
//        let finalScale: Float = 0.1
//
//        arView.scene.anchors[0].addChild(screen)
//        arView.scene.anchors[0].addChild(okoBot)
//        
//        let transOkoBot = Transform(scale: SIMD3(x: finalScale, y: finalScale, z: finalScale), rotation: simd_quatf(angle: 0, axis: SIMD3(x: 0, y: 0, z: 0)), translation: [-0.3, 0.3, 1.5])
//        
//        okoBot.move(to: transOkoBot, relativeTo: nil, duration: TimeInterval(2))
//    }
    
//    private func startAnimationFlex() {
//
//        self.serialQueue.sync {
//
//            if let animRes = self.dictAnimationRes1["flex1"] {
//                self.animationController = self.nodeGirl?.playAnimation(animRes)
//            }
//        }
//    }
    
//    private func startTimerFlex() {
//
//        self.serialQueue.sync {
////            self.timerAnimation = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
////
////                self.durationZoomCamera += 0.1
////
////                if self.durationZoomCamera >= self.timingFinishFlex1 {
////                    self.durationZoomCamera = 0
////                }
//
////                print ("timer flex", self.durationZoomCamera)
////            }
//        }
//    }
    
//    private func subAnim() {
//        
//        subAnimComplete = arView.scene.subscribe(to: AnimationEvents.PlaybackCompleted.self, on: self.nodeGirl, { event in
//            
//            self.serialQueue.sync {
//            
//            switch self.animateMode {
//            case .waiting:
//                
////                let flex = "flex" + String(self.flexCounter)
////                print ("awdhjbjhbhj", flex)
//                
//                self.animationController = self.nodeGirl?.playAnimation(self.dictAnimationRes1["flex1"]!)
//                
//                self.flexCounter += 1
//                
//            case .emoji:
//                
//                let emoji = "emoji" + String(self.emojiCounter)
//                print ("awdhjbjhbhj", emoji)
//                    
////                    self.videoPlayerEmoji?.advanceToNextItem()
//                    /// конец
////                    NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(_:)), name: AVPlayerItemDidPlayToEndTimeNotification, object: self.videoPlayerEmoji.currentItem)
//                    
//                    switch self.chooseLevel {
//                    case 1:
//                        
//                        if self.emojiCounter == 1 {
//                            self.animationController = self.nodeGirl?.playAnimation(self.dictAnimationRes1["emoji1"]!)
////                            self.animationController?.speed = 1.15
//                        }
//                        
//                        if self.emojiCounter == 2 {
//                            self.arSwitch.isOn = true
//                        }
//                    case 2:
//                        if self.emojiCounter == 1 {
//                            self.animationController = self.nodeGirl?.playAnimation(self.dictAnimationRes1["flex1"]!)
//                        }
//                        
//                        if self.emojiCounter == 2 {
//                            self.animationController = self.nodeGirl?.playAnimation(self.dictAnimationRes1["emoji2"]!)
//                        }
//                        
//                        if self.emojiCounter == 3 {
//                            self.arSwitch.isOn = true
//                        }
//                        self.animationController?.speed = 1.5
//                        
//                    default: break
//                    }
//                self.emojiCounter += 1
//            }
//            }
//        })
//    }
    
//    private func stopAnimationFlex() {
//        self.serialQueue.sync {
//
//            timerAnimation?.invalidate()
//            timerAnimation = nil
//        }
//    }
//
//    private func startAnimationEmoji() {
//        print ("debag debag startAnimationEmoji")
//
//        self.serialQueue.sync {
//
////            self.timerAnimation = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
////
////                self.durationZoomCamera += 0.01
////
////                if self.durationZoomCamera >= (self.timingFinishEmoji1 - self.timingStartEmoji1) {
////                    self.durationZoomCamera = 0
////                }
////            }
//
//            self.animateMode = .emoji
//        }
//    }
//
//    private func stopAnimationEmoji() {
////        self.serialQueue.sync {
//
//            self.emojiCounter = 1
//            self.animateMode = .waiting
//
//            timerAnimation?.invalidate()
//            timerAnimation = nil
////        }
//    }
    
//    private func stopDemo() {
//        self.stopAnimationEmoji()
//
//        switch chooseLevel {
//        case 1: stopDemoLevel1()
//        case 2:
//            arView.scene.anchors[0].children[2].removeFromParent()
//            arView.scene.anchors[0].children[2].removeFromParent()
////            nodeGirl?.model?.materials[3] = (nodeAvatar?.model?.materials[3])!
//            nodeGirl?.model?.materials[3] = self.materialTshirt
//        default: break
//        }
//    }
//
//    private func stopDemoLevel1() {
//        arView.scene.anchors[0].children[2].removeFromParent()
//        arView.scene.anchors[0].children[2].removeFromParent()
//            self.videoPlayerEmoji?.pause()
////            self.videoPlayerEmoji?.removeAllItems()
//            self.videoPlayerEmoji = nil
//
//            self.arrayPlayerItem.removeAll()
//            self.dowloadVideos()
//    }
    
}

