//
//  CleanFaceTrackViewController.swift
//  Oko Future
//
//  Created by Денис Калинин on 25.04.23.
//

import ARKit
import UIKit
import RealityKit
import ReplayKit

final class CleanFaceTrackViewController: UIViewController {
    
    private let photoVideoButton: UIButton = {
        let btn = UIButton()
        btn.isHidden = true
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.cgColor
        btn.backgroundColor = .black
//        btn.backgroundColor = .clear
        btn.setImage(UIImage(named: "okoLogoWhite"), for: .normal)
        return btn
    }()
    
    private var stepImageView: UIImageView = {
        let imgv = UIImageView(image: UIImage(named: "Step 1 (4)"))
        imgv.contentMode = .scaleAspectFill
        return imgv
    }()
    
    private var emoji: Emoji? = nil {
        didSet {
            if emoji != oldValue, let emoji = emoji {
                self.emoji = emoji
                self.changeVideo(emoji: emoji)
            }
        }
    }
    
    private var counter = 0 {
        didSet {
            if counter == 30 {
                reqvest()
                counter = 0
            }
        }
    }
    
    private var arView: ARView
    
    private let classifierService = OkoClassifierService()
    
    private var isOKO = false {
        didSet {
            if isOKO == true {
                stepImageView.image = UIImage(named: "S")
                photoVideoButton.isHidden = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.stepImageView.image = UIImage(named: "Step 2 (3)")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                        self.stepImageView.isHidden = true
                    })
                })
            }
        }
    }
    
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
        
        view.addSubview(stepImageView)
        view.addSubview(backButton)
        view.addSubview(photoVideoButton)
        backButton.addTarget(self, action: #selector(backButtonTap), for: .touchUpInside)
        
        photoVideoButton.addTarget(self, action: #selector(snapshotSave), for: .touchUpInside)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(recordScreen))
        photoVideoButton.addGestureRecognizer(longPressRecognizer)
        
        bindToImageClassifierService()
        
        dowloadVideos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        backButton.frame = CGRect(x: 21, y: 61, width: 48, height: 48)
        stepImageView.frame = view.frame
        photoVideoButton.frame = CGRect(x: (view.bounds.width - 80) / 2, y: view.bounds.height - 122, width: 80, height: 80)
        photoVideoButton.layer.cornerRadius = photoVideoButton.bounds.size.height / 2.0
        
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
    
    @objc func backButtonTap() {
        arView.removeFromSuperview()
        navigationController?.popViewController(animated: true)
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
              isOKO = true
//              print ("hjkhjjnk результ", result.identifier , result.confidence, isOKO)
          } else {
              isOKO = false
//              print ("hjkhjjnk результ", result.identifier , result.confidence, isOKO)
          }
      }
//        print (resultLog)
    }

    private func reqvest() {
        
        arView.snapshot(saveToHDR: false, completion: {image in
            
            if let img = image {
                self.classifierService.classifyImage(img)
            }
            
        })
        
    }
    
    @objc private func snapshotSave() {
        arView.snapshot(saveToHDR: false, completion: {image in
            UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            
        })
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {

        if let error = error {
            print("Error Saving ARKit Scene \(error)")
        } else {
            print("ARKit Scene Successfully Saved")
        }
    }

    
    @objc private func recordScreen(sender: UILongPressGestureRecognizer) {
        /// багулька с разрешением на запись экрана
        switch sender.state {
            
        case .began:
            RPScreenRecorder.shared().startRecording(handler: { error in
                guard let error = error else { return }
//                print ("htfghythyf", error.localizedDescription)
            })
        
        case .ended:
            RPScreenRecorder.shared().stopRecording { preview, err in
              guard let preview = preview else { print("no preview window"); return }
              preview.modalPresentationStyle = .overFullScreen
              preview.previewControllerDelegate = self
              self.present(preview, animated: true)
                
            }
        default:
            break
        }
    }
}

extension CleanFaceTrackViewController: RPPreviewViewControllerDelegate {
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
      previewController.dismiss(animated: true) { [weak self] in
      /// после исчезновения previewController
      }
    }
}

extension CleanFaceTrackViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        
        if let faceAnchor = anchors.first as? ARFaceAnchor {
            createOneAnchor(faceAnchor: faceAnchor)
        }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if !isOKO {
            counter += 1
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
