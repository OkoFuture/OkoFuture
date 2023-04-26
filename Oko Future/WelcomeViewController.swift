//
//  WelcomeViewController.swift
//  Oko Future
//
//  Created by Denis on 26.03.2023.
//

import UIKit
import SceneKit
import Combine
import RealityKit

final class WelcomeViewController: UIViewController {
    
    private let welcomeImage: UIImageView = {
        let img = UIImage(named: "Welcome")
        let imgV = UIImageView(image: img)
        imgV.contentMode = .scaleAspectFill
        return imgV
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(welcomeImage)
        welcomeImage.frame = view.frame
        
        uploadScene()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func uploadScene() {
        
        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        
        let sceneEntity = try! ModelEntity.loadModel(named: "OKO-location_v3", in: nil)
        sceneEntity.setScale(SIMD3(x: 2, y: 2, z: 2), relativeTo: sceneEntity)
        
//        let entity = try! ModelEntity.loadModel(named: "OKO location_v2", in: nil)
//        entity.setScale(SIMD3(x: 0.1, y: 0.1, z: 0.1), relativeTo: entity)
        
        let cameraEntity = PerspectiveCamera()
        cameraEntity.camera.fieldOfViewInDegrees = 39
        
        var nodeGirl: Entity?
        var nodeAvatar: Entity?
        
        let scaleAvatar: Float = 1.5
        
        let arrayNameScene = ["dressed_avatar_2504.usdz", "dressed_girl_2104.usdz"]
        
        var cancellable: AnyCancellable? = nil
         
          cancellable = ModelEntity.loadModelAsync(named: arrayNameScene[1])
            .sink(receiveCompletion: { error in
              print("Unexpected error: \(error)")
              cancellable?.cancel()
            }, receiveValue: { entity in

                entity.setScale(SIMD3(x: scaleAvatar, y: scaleAvatar, z: scaleAvatar), relativeTo: entity)
                
                nodeAvatar = entity
                
                cancellable = ModelEntity.loadModelAsync(named: arrayNameScene[0])
                  .sink(receiveCompletion: { error in
                    print("Unexpected error: \(error)")
                    cancellable?.cancel()
                  }, receiveValue: { entity in

                      entity.setScale(SIMD3(x: scaleAvatar, y: scaleAvatar, z: scaleAvatar), relativeTo: entity)
                      
                      nodeGirl = entity

                      let generalVC = GeneralViewController(arView: arView, sceneEntity: sceneEntity, nodeGirl: nodeGirl!, nodeAvatar: nodeAvatar!)
                      
                      self.navigationController?.pushViewController(generalVC, animated: true)

                      cancellable?.cancel()
                  })
            })
        
    }
    
}
