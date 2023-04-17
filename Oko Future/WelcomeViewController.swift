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
    }
    
    private func uploadScene() {
            
        let generalVC = GeneralViewController()
        
        let anchor = AnchorEntity(world: generalVC.startPoint)
        generalVC.sceneView.scene.addAnchor(anchor)
        
        let entity = try! ModelEntity.loadModel(named: "OKO location_v2", in: nil)
        entity.setScale(SIMD3(x: 0.1, y: 0.1, z: 0.1), relativeTo: entity)
        
        anchor.addChild(entity)
        
        let scaleAvatar: Float = 1.65
        
        var cancellable: AnyCancellable? = nil
         
          cancellable = ModelEntity.loadModelAsync(named: generalVC.arrayNameScene[1])
            .sink(receiveCompletion: { error in
              print("Unexpected error: \(error)")
              cancellable?.cancel()
            }, receiveValue: { entity in

                entity.setScale(SIMD3(x: scaleAvatar, y: scaleAvatar, z: scaleAvatar), relativeTo: entity)
                entity.transform.translation = SIMD3(x: 0, y: 0, z: 0.3)
                
                generalVC.nodeAvatar = entity
                
                cancellable = ModelEntity.loadModelAsync(named: generalVC.arrayNameScene[0])
                  .sink(receiveCompletion: { error in
                    print("Unexpected error: \(error)")
                    cancellable?.cancel()
                  }, receiveValue: { entity in

                      entity.setScale(SIMD3(x: scaleAvatar, y: scaleAvatar, z: scaleAvatar), relativeTo: entity)
                      entity.transform.translation = SIMD3(x: 0, y: 0, z: 0.3)
                      
                      generalVC.nodeGirl = entity
                      
                      anchor.addChild(entity)

                      self.navigationController?.pushViewController(generalVC, animated: true)

                      cancellable?.cancel()
                  })
            })
        
    }
    
}
