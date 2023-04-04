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
    private let videoPlayer = AVPlayer()
    private var isVideoCreate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(false, animated:false)
        view.addSubview(arView)
        
        guard let referenceImages = ARReferenceImage.referenceImages(
            inGroupNamed: "rusRap", bundle: nil)
        else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        let configuration = ARImageTrackingConfiguration()
        configuration.isAutoFocusEnabled = true
        configuration.trackingImages = referenceImages
        configuration.maximumNumberOfTrackedImages = 1
        
        arView.session.delegate = self
        arView.frame = view.frame
        
        arView.session.run(configuration)
    }
}

extension ArViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
                
        if !isVideoCreate {
            isVideoCreate = true
            
            guard let imageAnchor = anchors[0] as? ARImageAnchor else {
                print("Problems loading anchor.")
                return
            }
            
            guard let path = Bundle.main.path(forResource: "hd1833", ofType: "mov") else {
                print("Unable to find video file.")
                return
            }
            
            let videoURL = URL(fileURLWithPath: path)
            let playerItem = AVPlayerItem(url: videoURL)
            let videoPlayer = AVPlayer(playerItem: playerItem)
            let videoMaterial = VideoMaterial(avPlayer: videoPlayer)
            
            let width = Float(imageAnchor.referenceImage.physicalSize.width * 1.03)
            let height = Float(imageAnchor.referenceImage.physicalSize.height * 1.03)

            let videoPlane = ModelEntity(mesh: .generatePlane(width: width, depth: height, cornerRadius: 0.3), materials: [videoMaterial])
            
            let anchorEntity = AnchorEntity()
            anchorEntity.addChild(videoPlane)
            arView.scene.addAnchor(anchorEntity)
            anchorEntity.transform.matrix = imageAnchor.transform
            videoPlayer.play()
        }
    }

            func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
//                anchors.compactMap { $0 as? ARImageAnchor }.forEach {
//                     let anchorEntity = imageAnchorToEntity[$0]
//                         anchorEntity?.transform.matrix = $0.transform
//                }
                
                guard let imageAnchor = anchors[0] as? ARImageAnchor else {
                    print("Problems loading anchor.")
                    return
                }
                
                if imageAnchor.isTracked {
//                    videoPlayer.play()
                } else {
//                    videoPlayer.pause()
                }
            }

}
